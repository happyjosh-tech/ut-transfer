ALTER VIEW [transfer].vReversal20x24h AS
SELECT
    *,
    CASE WHEN 20 > ISNULL(expireCount, 0) AND reversed = 0 THEN 1 ELSE 0 END reverseIssuer,
    CASE WHEN 20 > ISNULL(expireCountLedger, 0) AND reversedLedger = 0 AND issuerId != ledgerId THEN 1 ELSE 0 END reverseLedger
FROM
    [transfer].[vReversal]
WHERE
    (20 > ISNULL(expireCount, 0) OR 20 > ISNULL(expireCountLedger, 0)) AND
    transferDateTime > DATEADD(DAY, -1, GETDATE()) AND
    channelType IN ('ATM', 'web')
