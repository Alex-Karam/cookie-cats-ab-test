SELECT
    COUNT(*) AS imported_rows,
    COUNT(DISTINCT userid) AS unique_player_ids,
    COUNT(CASE
        WHEN userid IS NULL OR userid NOT REGEXP '^[1-9][0-9]*$' THEN 1
    END) AS invalid_player_ids,
    COUNT(CASE
        WHEN version IS NULL
          OR CAST(version AS BINARY) NOT IN ('gate_30', 'gate_40') THEN 1
    END) AS invalid_assignments,
    COUNT(CASE
        WHEN retention_1 IS NULL
          OR CAST(LOWER(retention_1) AS BINARY) NOT IN ('true', 'false') THEN 1
    END) AS invalid_day_1_flags,
    COUNT(CASE
        WHEN retention_7 IS NULL
          OR CAST(LOWER(retention_7) AS BINARY) NOT IN ('true', 'false') THEN 1
    END) AS invalid_day_7_flags
FROM cookie_cats_ab_test.players_raw;
########################################################

SELECT
    version,
    COUNT(*) AS assigned_players,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS share_pct
FROM cookie_cats_ab_test.players_raw
GROUP BY version
ORDER BY version;
########################################################

WITH counts_by_group AS (
    SELECT
        version,
        COUNT(*) AS assigned_players,
        COUNT(CASE WHEN LOWER(retention_1) = 'true' THEN 1 END) AS day_1_returns,
        COUNT(CASE WHEN LOWER(retention_7) = 'true' THEN 1 END) AS day_7_returns
    FROM cookie_cats_ab_test.players_raw
    GROUP BY version
)
SELECT
    version,
    assigned_players,
    day_1_returns,
    ROUND(100.0 * day_1_returns / assigned_players, 2) AS day_1_retention_pct,
    day_7_returns,
    ROUND(100.0 * day_7_returns / assigned_players, 2) AS day_7_retention_pct
FROM counts_by_group
ORDER BY version;
########################################################




























