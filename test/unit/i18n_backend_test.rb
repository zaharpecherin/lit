require 'test_helper'

class I18nBackendTest < ActiveSupport::TestCase
  fixtures 'lit/locales'
  class Backend < Lit::I18nBackend
  end

  def setup
    @old_backend = I18n.backend
    @old_locale = I18n.locale
    @old_humanize_key = Lit.humanize_key
    @old_available_locales = ::Rails.configuration.i18n.available_locales
  end

  def teardown
    ::Rails.configuration.i18n.available_locales = @old_available_locales
    I18n.backend = @old_backend
    I18n.backend = @old_backend
    I18n.locale = @old_locale
    Lit.humanize_key = @old_humanize_key
  end

  test 'properly returns available locales' do
    I18n.backend = Backend.new(Lit.loader.cache)
    assert_equal 2, I18n.backend.available_locales.count
    ::Rails.configuration.i18n.available_locales = [:en, :pl]
    I18n.backend = Backend.new(Lit.loader.cache)
    assert_equal 2, I18n.backend.available_locales.count
    ::Rails.configuration.i18n.available_locales = [:en]
    I18n.backend = Backend.new(Lit.loader.cache)
    assert_equal 1, I18n.backend.available_locales.count
  end

  test 'auto-humanizes key when Lit.humanize_key=true' do
    Lit.humanize_key = true
    I18n.locale = :en
    test_key = 'this_will_get_humanized'
    humanized_key = 'This will get humanized'
    assert_equal I18n.t(test_key), humanized_key
    lk = Lit::LocalizationKey.find_by localization_key: test_key
    locale = Lit::Locale.find_by locale: 'en'
    l = lk.localizations.where(locale: locale).first
    assert_equal l.default_value, humanized_key
  end

  test 'wont humanize key, if key is ignored' do
    Lit.humanize_key = true
    I18n.locale = :en
    test_key = 'date.this_will_get_humanized'
    assert_equal I18n.t(test_key), 'translation missing: en.date.this_will_get_humanized'
    lk = Lit::LocalizationKey.find_by localization_key: test_key
    locale = Lit::Locale.find_by locale: 'en'
    l = lk.localizations.where(locale: locale).first
    assert_nil l.default_value
  end
end
