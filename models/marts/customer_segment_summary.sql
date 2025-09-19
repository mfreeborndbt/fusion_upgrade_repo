select
    SEGMENT,
    count(*) as customer_count,
    round(avg(LIFETIME_SPEND), 2) as avg_lifetime_spend
from {{ ref('customer_segments_python') }}
group by SEGMENT
order by avg_lifetime_spend desc
