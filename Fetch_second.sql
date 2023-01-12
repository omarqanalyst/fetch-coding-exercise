-- Important note: Table Receipts has column 'rewardsReceiptItemList' and it contains text with barcode (foreign key to Table Brands). The query assumes there's an additional table or one needs to be created: the foreign key for the rewardsReceiptItemList table is 'barcode'.

-- What are the top 5 brands by receipts scanned for most recent month?
WITH most_recent_month AS (
  SELECT DATE_TRUNC('month', MAX(dateScanned)) AS month
  FROM receipts
)
SELECT
  brand.name,
  COUNT(*) AS receipts_scanned
FROM receipts
JOIN rewardsReceiptItemList ON rewardsReceiptItemList.barcode = receipts.barcode
JOIN brand ON brand._id = rewardsReceiptItemList.brand
JOIN most_recent_month ON DATE_TRUNC('month', receipts.dateScanned) = most_recent_month.month
GROUP BY brand.name
ORDER BY receipts_scanned DESC
LIMIT 5;



-- How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
WITH previous_month AS (
  SELECT DATE_TRUNC('month', MAX(dateScanned)) - INTERVAL '1 month' AS month
  FROM receipts
)
SELECT
  brand.name,
  COUNT(*) AS receipts_scanned
FROM receipts
JOIN rewardsReceiptItemList ON rewardsReceiptItemList.barcode = receipts.barcode
JOIN brand ON brand._id = rewardsReceiptItemList.brand
JOIN previous_month ON DATE_TRUNC('month', receipts.dateScanned) = previous_month.month
GROUP BY brand.name
ORDER BY receipts_scanned DESC
LIMIT 5;


-- When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
WITH accepted_rejected_receipts AS (
  SELECT totalSpent, rewardsReceiptStatus
  FROM receipts
  WHERE rewardsReceiptStatus IN ('Accepted', 'Rejected')
)
SELECT 
  rewardsReceiptStatus,
  AVG(totalSpent) as average_spend
FROM accepted_rejected_receipts
GROUP BY rewardsReceiptStatus


-- When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
WITH accepted_items AS (
  SELECT
    SUM(purchasedItemCount) as accepted_items
  FROM receipts
  WHERE rewardsReceiptStatus = 'Accepted'
), rejected_items AS (
  SELECT
    SUM(purchasedItemCount) as rejected_items
  FROM receipts
  WHERE rewardsReceiptStatus = 'Rejected'
)
SELECT
  accepted_items,
  rejected_items,
  CASE
    WHEN accepted_items > rejected_items THEN 'Accepted'
    WHEN accepted_items < rejected_items THEN 'Rejected'
    ELSE 'Equal'
  END as greater_status
FROM accepted_items, rejected_items;


-- Which brand has the most spend among users who were created within the past 6 months?
WITH recent_users AS (
  SELECT _id
  FROM users
  WHERE createdDate >= NOW() - INTERVAL '6 months'
)
SELECT
  brand.name,
  SUM(receipts.totalSpent) as total_spend
FROM receipts
JOIN rewardsReceiptItemList ON rewardsReceiptItemList.barcode = receipts.barcode
JOIN brand ON brand._id = rewardsReceiptItemList.brand
JOIN recent_users ON recent_users._id = receipts.userId
GROUP BY brand.name
ORDER BY total_spend DESC
LIMIT 1;


-- Which brand has the most transactions among users who were created within the past 6 months?
WITH recent_users AS (
  SELECT userId
  FROM users
  WHERE createdDate >= NOW() - INTERVAL '6 months'
)
SELECT 
  brand.name, 
  COUNT(DISTINCT receipts.userId) as transaction_count
FROM recent_users
JOIN receipts ON recent_users.userId = receipts.userId
JOIN rewardsReceiptItemList ON receipts.rewardsReceiptItemList = rewardsReceiptItemList.barcode
JOIN brand ON rewardsReceiptItemList.barcode = brand._id
GROUP BY brand.name
ORDER BY transaction_count DESC
LIMIT 1

