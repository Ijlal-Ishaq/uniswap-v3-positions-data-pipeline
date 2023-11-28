WITH mint_amounts AS (
    SELECT
        owner,
        pool,
        tick_lower,
        tick_upper,
        SUM(amount) AS mint_total_amount,
    FROM {{ ref('mint_logs') }}
    GROUP BY owner, pool, tick_lower, tick_upper
),
burn_amounts AS (
    SELECT
        owner,
        pool,
        tick_lower,
        tick_upper,
        SUM(amount) AS burn_total_amount,
    FROM {{ ref('burn_logs') }}
    GROUP BY owner, pool, tick_lower, tick_upper
)

SELECT
    m.owner,
    m.pool,
    m.tick_lower,
    m.tick_upper,
    COALESCE(m.mint_total_amount, 0) - COALESCE(b.burn_total_amount, 0) AS liquidity,
FROM mint_amounts m
FULL OUTER JOIN burn_amounts b
    ON m.owner = b.owner
    AND m.pool = b.pool
    AND m.tick_lower = b.tick_lower
    AND m.tick_upper = b.tick_upper
