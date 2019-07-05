ALTER PROCEDURE [transfer].[push.addToQueueIssuer]
    @transferId BIGINT,
    @type VARCHAR(50),
    @message VARCHAR(250),
    @details XML
AS
SET NOCOUNT ON

UPDATE
    [transfer].[transfer]
SET
    issuerTxState = 15
WHERE
    transferId = @transferId AND
    issuerTxState IS NULL

DECLARE @COUNT INT = @@ROWCOUNT
EXEC [transfer].[push.event]
    @transferId = @transferId,
    @type = @type,
    @state = 'addedToQueue',
    @source = 'issuer',
    @message = @message,
    @udfDetails = @details

IF @COUNT <> 1 RAISERROR('transfer.failIssuer', 16, 1);
