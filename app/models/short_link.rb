class ShortLink < ApplicationRecord
  self.table_name = "short_links"

  VALID_ALIAS_PATTERN = /\A[A-Za-z0-9]{8}\z/

  before_validation :set_default_alias, on: :create
  before_validation :set_expiration, on: :create
  before_validation :normalize_original_url

  validates :original_url, presence: true
  validates :alias, presence: true, uniqueness: true, format: { with: VALID_ALIAS_PATTERN }

  validate :original_url_must_be_http_or_https

  def self.base_url
    ENV.fetch("APP_BASE_URL", "http://localhost:3000")
  end

  def self.find_by_alias!(alias_value)
    find_by!("alias = ?", alias_value)
  end

  def short_url
    "#{self.class.base_url}/#{self[:alias]}"
  end

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def safe_redirect_target?
    return false if original_url.blank?

    uri = URI.parse(original_url)
    uri.is_a?(URI::HTTP) && %w[http https].include?(uri.scheme.to_s.downcase) && uri.host.present?
  rescue URI::InvalidURIError
    false
  end

  def generate_alias
    loop do
      candidate = SecureRandom.alphanumeric(8)
      return candidate unless ShortLink.where(alias: candidate).exists?
    end
  end

  private

  def set_default_alias
    self[:alias] = generate_alias if self[:alias].blank?
  end

  def set_expiration
    self[:expires_at] = Time.current + 2.years if self[:expires_at].blank?
  end

  def normalize_original_url
    return if original_url.nil?

    self[:original_url] = original_url.strip
  end

  def original_url_must_be_http_or_https
    return if original_url.blank?

    uri = URI.parse(original_url)

    if uri.scheme.blank?
      errors.add(:original_url, :missing_scheme)
      return
    end

    unless %w[http https].include?(uri.scheme.downcase)
      errors.add(:original_url, :unsupported_scheme)
      return
    end

    unless uri.host.present?
      errors.add(:original_url, :malformed)
    end
  rescue URI::InvalidURIError
    errors.add(:original_url, :malformed)
  end
end
