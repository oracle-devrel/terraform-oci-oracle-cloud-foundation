set define off;
set serveroutput on;

create or replace function get_customer_profile_json(
  p_customer_name in varchar2
)
return clob
is
  v_result clob;
begin
  select json_object(
    key 'customer_id' value customer_id,
    key 'full_name' value json_value(profile_json, '$.personalInfo.fullName'),
    key 'email' value json_value(profile_json, '$.personalInfo.email'),
    key 'phone_number' value json_value(profile_json, '$.personalInfo.phoneNumber'),
    key 'date_of_birth' value json_value(profile_json, '$.personalInfo.dateOfBirth'),
    key 'gender' value json_value(profile_json, '$.personalInfo.gender'),
    key 'account_created' value json_value(profile_json, '$.accountInfo.accountCreated'),
    key 'loyalty_points' value json_value(profile_json, '$.accountInfo.loyaltyPoints'),
    key 'loyalty_tier' value json_value(profile_json, '$.accountInfo.loyaltyTier'),
    key 'email_verified' value json_value(profile_json, '$.accountInfo.emailVerified'),
    key 'sms_opt-in' value json_value(profile_json, '$.accountInfo.smsOptIn'),
    key 'preferred_style' value json_value(profile_json, '$.clothingPreferences.preferredStyle'),
    key 'favorite_brand_1' value json_value(profile_json, '$.clothingPreferences.favoriteBrands[0]'),
    key 'favorite_brand_2' value json_value(profile_json, '$.clothingPreferences.favoriteBrands[1]'),
    key 'favorite_brand_3' value json_value(profile_json, '$.clothingPreferences.favoriteBrands[2]'),
    key 'favorite_color_1' value json_value(profile_json, '$.clothingPreferences.favoriteColors[0]'),
    key 'favorite_color_2' value json_value(profile_json, '$.clothingPreferences.favoriteColors[1]'),
    key 'favorite_color_3' value json_value(profile_json, '$.clothingPreferences.favoriteColors[2]'),
    key 'favorite_color_4' value json_value(profile_json, '$.clothingPreferences.favoriteColors[3]'),
    key 'preferred_size_tops' value json_value(profile_json, '$.clothingPreferences.preferredSize.tops'),
    key 'preferred_size_bottoms' value json_value(profile_json, '$.clothingPreferences.preferredSize.bottoms'),
    key 'preferred_size_shoes' value json_value(profile_json, '$.clothingPreferences.preferredSize.shoes'),
    key 'newsletter_subscribed' value json_value(profile_json, '$.marketingPreferences.newsletterSubscribed'),
    key 'promotional_emails' value json_value(profile_json, '$.marketingPreferences.promotionalEmails'),
    key 'marketing_category_1' value json_value(profile_json, '$.marketingPreferences.categories[0]'),
    key 'marketing_category_2' value json_value(profile_json, '$.marketingPreferences.categories[1]'),
    key 'marketing_category_3' value json_value(profile_json, '$.marketingPreferences.categories[2]'),
    key 'total_orders' value json_value(profile_json, '$.purchaseHistory.totalOrders'),
    key 'lifetime_value' value json_value(profile_json, '$.purchaseHistory.lifetimeValue'),
    key 'average_order_value' value json_value(profile_json, '$.purchaseHistory.averageOrderValue'),
    key 'last_order_date' value json_value(profile_json, '$.purchaseHistory.lastOrderDate'),
    key 'preferred_stores' value json_value(profile_json, '$.purchaseHistory.preferredStores'),
    key 'shipping_address_label' value json_value(profile_json, '$.shippingAddresses[0].label'),
    key 'shipping_address_id' value json_value(profile_json, '$.shippingAddresses[0].addressId'),
    key 'shipping_address_street' value json_value(profile_json, '$.shippingAddresses[0].street'),
    key 'shipping_address_city' value json_value(profile_json, '$.shippingAddresses[0].city'),
    key 'shipping_address_state' value json_value(profile_json, '$.shippingAddresses[0].state'),
    key 'shipping_address_zipcode' value json_value(profile_json, '$.shippingAddresses[0].zipCode'),
    key 'shipping_address_country' value json_value(profile_json, '$.shippingAddresses[0].country'),
    key 'shipping_address_is default' value json_value(profile_json, '$.shippingAddresses[0].isDefault')
    returning clob
  )
  into v_result
  from customer_profile_oracle
  where upper(full_name) = upper(p_customer_name)
  fetch first 1 row only;

  return v_result;

exception
  when no_data_found then
    return to_clob('{"error":"customer not found"}');
  when others then
    return to_clob(
      '{"error":"database error","message":"' ||
      replace(replace(sqlerrm, '"', '\"'), chr(10), ' ') ||
      '"}'
    );
end get_customer_profile_json;
/
show errors;

exit;
/