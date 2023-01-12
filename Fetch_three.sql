-- 1. Verify if primary keys are unique.
SELECT _id, COUNT(*)
FROM brand -- repeat for other 2 columns
GROUP BY _id
HAVING COUNT(*) > 1

-- 2. Nested data for columns needs to be extracted to a new table or deconstructed  to new columns. This would facilitate future querying. 
-- Refer to console.log outputs for file exploreDFS.js