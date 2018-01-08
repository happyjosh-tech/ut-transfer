ALTER PROCEDURE [transfer].[push.reverseCreate]
    @transferId bigint,
    @reverseAmount money,
    @isPartial BIT = 0,
    @issuerId varchar(50),
    @issuerChannelId char(4),
    @transferIdAcquirer varchar(50) = NULL,
    @transferDateTime datetime2(0) = NULL,
    @localDateTime varchar(14) = NULL, 
    @requestSourceId char(6) = NULL
AS
DECLARE @reverseId BIGINT

IF @requestSourceId = 'switch'
SET @reverseId = (SELECT TOP 1 reverseId FROM [transfer].[reverse] 
				WHERE 
				   requestSourceId = 'switch'
				AND [issuerTxState] = 4
				AND [issuerResponseCode] = 92
				AND transferId=@transferId )

IF @reverseId IS NULL
BEGIN
    INSERT INTO [transfer].[reverse] (
	   transferId,
	   reverseAmount,
	   isPartial,
	   issuerTxState,
	   issuerId,
	   issuerChannelId,
	   transferDateTime,
	   localDateTime,
	   transferIdAcquirer,
	   requestSourceId,
	   createdOn,
	   updatedOn
    )
    VALUES (
	   @transferId,
	   @reverseAmount,
	   @isPartial,
	   1,
	   @issuerId,
	   @issuerChannelId,
	   ISNULL(@transferDateTime, GETDATE()),
	   @localDateTime,
	   @transferIdAcquirer,
	   @requestSourceId,
	   SYSDATETIMEOFFSET(),
	   SYSDATETIMEOFFSET()
    )
    SET @reverseId=SCOPE_IDENTITY()
END
EXEC [transfer].[push.event]
    @transferId = @transferId,
    @type = 'transfer.reverse',
    @state = 'request',
    @source = 'acquirer',
    @message = NULL,
    @udfDetails = NULL

SELECT @reverseId reverseId 
