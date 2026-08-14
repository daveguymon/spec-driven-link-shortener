require "rails_helper"

RSpec.describe ShortLink, type: :model do
  describe "validations" do
    it "accepts valid http and https destinations" do
      valid = described_class.new({ "original_url" => "https://example.com", "alias" => "ABCD1234" })
      expect(valid.valid?).to be true
    end

    it "rejects blank destinations with a distinct required message" do
      blank = described_class.new({ "original_url" => "", "alias" => "ABCD1234" })

      expect(blank.valid?).to be false
      expect(blank.errors[:original_url]).to include("Please enter a destination URL.")
    end

    it "rejects scheme-less destinations with corrective guidance" do
      missing_scheme = described_class.new({ "original_url" => "example.com/path", "alias" => "ABCD1234" })

      expect(missing_scheme.valid?).to be false
      expect(missing_scheme.errors[:original_url]).to include("must start with http:// or https:// (example: https://example.com).")
    end

    it "rejects unsupported schemes with allowed scheme guidance" do
      ftp = described_class.new({ "original_url" => "ftp://example.com", "alias" => "ABCD1234" })
      javascript = described_class.new({ "original_url" => "javascript:alert(1)", "alias" => "ABCD1235" })

      expect(ftp.valid?).to be false
      expect(ftp.errors[:original_url]).to include("must use http:// or https://. Other schemes are not supported.")

      expect(javascript.valid?).to be false
      expect(javascript.errors[:original_url]).to include("must use http:// or https://. Other schemes are not supported.")
    end

    it "rejects malformed http/https URLs" do
      malformed = described_class.new({ "original_url" => "https://", "alias" => "ABCD1234" })

      expect(malformed.valid?).to be false
      expect(malformed.errors[:original_url]).to include("is not a valid URL. Please enter a full URL like https://example.com/page.")
    end

    it "normalizes leading/trailing whitespace before validation" do
      with_whitespace = described_class.new({ "original_url" => "  https://example.com/path  ", "alias" => "ABCD1234" })

      expect(with_whitespace.valid?).to be true
      expect(with_whitespace.original_url).to eq("https://example.com/path")
    end
  end

  describe "alias generation" do
    it "creates an 8-character random alias and keeps it unique" do
      link = described_class.new({ "original_url" => "https://example.com" })
      expect(link.generate_alias).to match(/\A[A-Za-z0-9]{8}\z/)

      described_class.create!({ "original_url" => "https://example.com", "alias" => "UNIQ1234" })
      other = described_class.new({ "original_url" => "https://example.org", "alias" => "UNIQ1234" })
      expect(other.valid?).to be false
      expect(other.errors[:alias]).to include("has already been taken")
    end
  end

  describe "redirect safety" do
    it "only allows safe http and https targets for redirects" do
      link = described_class.new({ "original_url" => "https://example.com", "alias" => "SAFE1234" })
      expect(link.safe_redirect_target?).to be true

      unsafe = described_class.new({ "original_url" => "javascript:alert(1)", "alias" => "BAD12345" })
      expect(unsafe.safe_redirect_target?).to be false
    end
  end

  describe "expiry" do
    it "sets the expiration to exactly two years from creation" do
      link = described_class.create!({ "original_url" => "https://example.com" })
      expect(link.expires_at).to be_within(1.second).of(link.created_at + 2.years)
      expect(link.expired?).to be false

      expired_link = described_class.new({ "original_url" => "https://example.org", "alias" => "OLD1234", "expires_at" => 3.years.ago })
      expect(expired_link.expired?).to be true
    end
  end
end
