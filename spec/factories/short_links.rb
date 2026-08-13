FactoryBot.define do
  factory :short_link do
    original_url { "https://example.com" }
    expires_at { 2.years.from_now }

    initialize_with do
      new(attributes.merge(alias: "ABCD1234"))
    end
  end
end
