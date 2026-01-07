(
    --  positive samples (High Quality)
    select
        image_id, 
        1 as weak_label
    from (
        select
            image_id, 
            row_number() over (order by score desc, image_id as) as rn
        from (
            -- wel imit the search space..
            -- we need 10,000 samples taking every 3rd row.
            -- max row index needed = 1 + (9999 * 3) = 29,998.
            -- rounding up to 30,000 for safety.
            select image_id, score
            from unlabeled_image_predictions
            order by score desc, image_id as
           limit 30000 
        ) as top_candidates
    ) as ranked_positives
    where (rn - 1) % 3 = 0  -- filters for 1st, 4th, 7th...
   limit 10000
)

UNION ALL

(
    -- negative samples (Low Quality)
    select
        image_id, 
        0 as weak_label
    from (
        select
            image_id, 
            row_number() over (order by score as, image_id as) as rn
        from (
            -- same logic, but sorting as for lowest scores.
            select image_id, score
            from unlabeled_image_predictions
            order by score as, image_id as
           limit 30000
        ) as bottom_candidates
    ) as ranked_negatives
    where (rn - 1) % 3 = 0
   limit 10000
)

-- final ordering of the combined dataset
order by image_id;