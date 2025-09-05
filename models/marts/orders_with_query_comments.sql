{{
  config(
    materialized='table',
    description='Orders model with dynamic query comments - Fusion blocker'
  )
}}

{{ query_comment(include_performance_metrics=true, custom_metadata={'model_type': 'analytics', 'priority': 'high'}) }}

-- This model uses the query_comment() macro which creates a Fusion migration blocker
-- Query comment macros inject dynamic metadata into SQL which may not be supported
-- Now includes macro argument validation testing with validate_macro_args flag

with orders_base as (
    {{ query_comment(custom_metadata={'step': 'base_data_load'}) }}
    select * from {{ ref('orders') }}
),

customers as (
    {{ query_comment() }}
    select * from {{ ref('customers') }}
),

-- Enhanced orders with comment-tracked transformations
orders_enhanced as (
    {{ query_comment() }}
    select
        o.order_id,
        o.customer_id,
        o.location_id,
        o.ordered_at,
        o.subtotal,
        o.tax_paid,
        o.order_total,
        
        -- Customer enrichment with query tracking
        c.customer_name,
        c.customer_type,
        c.lifetime_spend,
        c.count_lifetime_orders,
        
        -- Calculated fields with audit trail
        case 
            when o.order_total > 1000 then 'Premium Order'
            when o.order_total > 500 then 'Standard Order'
            else 'Basic Order'
        end as order_tier,
        
        -- Performance metrics with tracking
        row_number() over (partition by o.customer_id order by o.ordered_at) as customer_order_number,
        lag(o.ordered_at) over (partition by o.customer_id order by o.ordered_at) as previous_order_date,
        
        -- Query comment metadata embedded in data
        '{{ run_started_at }}' as query_execution_time,
        '{{ invocation_id }}' as dbt_invocation_id,
        'query_comment_enabled' as processing_type
        
    from orders_base o
    left join customers c on o.customer_id = c.customer_id
),

-- Final aggregations with extensive query commenting
final_orders_with_comments as (
    {{ query_comment() }}
    select
        *,
        
        -- Advanced calculations requiring audit trail
        case 
            when previous_order_date is not null 
            then datediff('day', previous_order_date, ordered_at)
            else null 
        end as days_between_orders,
        
        -- Revenue impact analysis
        order_total / nullif(customer_order_number, 0) as avg_order_value_trend,
        
        -- Customer segmentation with tracking
        case 
            when customer_type = 'returning' and order_tier = 'Premium Order' then 'VIP Customer'
            when customer_type = 'returning' and order_tier = 'Standard Order' then 'Loyal Customer'
            when customer_type = 'new' and order_tier = 'Premium Order' then 'High Value New Customer'
            else 'Standard Customer'
        end as customer_segment_detailed,
        
        -- Query performance metadata
        current_timestamp as record_processed_at,
        datediff('second', '{{ run_started_at }}', current_timestamp) as processing_duration_seconds
        
    from orders_enhanced
)

{{ query_comment() }}
/* Final query with comprehensive commenting and audit trail */
/* This query demonstrates extensive use of query_comment() macro */
/* Each subquery includes dynamic metadata injection */

select * from final_orders_with_comments
order by ordered_at desc

{{ query_comment() }}
/* End of query - total execution tracked and logged */
