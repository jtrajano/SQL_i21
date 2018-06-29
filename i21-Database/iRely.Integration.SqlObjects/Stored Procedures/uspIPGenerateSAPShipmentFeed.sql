CREATE PROCEDURE [dbo].[uspIPGenerateSAPShipmentFeed]
	@strLoadNo NVARCHAR(MAX),
	@intUserId int
AS
BEGIN TRY

Declare @intLoadId int,
		@strDeliveryNo nvarchar(100),
		@strErrMsg nvarchar(max),
		@intLoadStgId int

If ISNULL(@strLoadNo,'')=''
	RaisError('Invalid Load No.',16,1)

Select @intLoadId=intLoadId,@strDeliveryNo=strExternalShipmentNumber from tblLGLoad Where strLoadNumber=@strLoadNo

If @intLoadId is null
	RaisError('Load No does not exist.',16,1)

If ISNULL(@strDeliveryNo,'')<>''
	RaisError('Delivery No already exist.',16,1)

Select TOP 1 @intLoadStgId=intLoadStgId from tblLGLoadStg Where intLoadId=@intLoadId 
		AND UPPER(strRowState)='ADDED' AND strFeedStatus='Ack Rcvd' AND strMessage<>'Success'
		Order by intLoadStgId

If @intLoadStgId>0
Begin
	Exec uspLGReprocessToLoadStg @intLoadId,'Added'
End
Else
	RaisError('Unable to send feed.',16,1)

END TRY

BEGIN CATCH
 SET @strErrMsg = ERROR_MESSAGE()  
 RAISERROR(@strErrMsg, 16, 1, 'WITH NOWAIT')  
END CATCH
