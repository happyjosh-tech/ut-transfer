ALTER PROCEDURE [transfer].[push.confirmAcquirer]
    @transferId bigint
AS
SET NOCOUNT ON

UPDATE
    [transfer].[transfer]
SET
    acquirerTxState = 2
WHERE
    transferId = @transferId AND
    acquirerTxState in (1, 2)

IF @@ROWCOUNT <> 1 RAISERROR('transfer.confirmAcquirer', 16, 1);
