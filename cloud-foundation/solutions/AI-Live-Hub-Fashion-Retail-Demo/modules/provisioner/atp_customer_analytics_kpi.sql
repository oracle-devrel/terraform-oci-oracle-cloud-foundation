set define off;
set serveroutput on;

begin
  execute immediate 'drop table customer_analytics_kpi purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/

create table customer_analytics_kpi (
  customer_id                 number primary key,
  full_name                   varchar2(255),
  email                       varchar2(255),
  gender                      varchar2(50),
  date_of_birth               date,
  age                         number,
  phone_number                varchar2(100),
  account_created_date        timestamp,
  customer_tenure_days        number,
  loyalty_tier                varchar2(50),
  loyalty_points              number,
  email_verified              number(1),
  sms_opt_in                  number(1),
  total_orders                number,
  lifetime_value              number(12,2),
  average_order_value         number(12,2),
  last_order_date             date,
  days_since_last_order       number,
  preferred_store             varchar2(255),
  order_frequency             number(10,2),
  is_active_customer          number(1),
  customer_segment            varchar2(50),
  newsletter_subscribed       number(1),
  promotional_emails          number(1),
  marketing_categories_count  number,
  preferred_style             varchar2(100),
  favorite_colors_count       number,
  favorite_brands_count       number,
  city                        varchar2(100),
  state                       varchar2(100),
  country                     varchar2(100)
);

comment on table customer_analytics_kpi is 'Demo analytics dataset simulating Databricks customer KPIs.';

exit;
/