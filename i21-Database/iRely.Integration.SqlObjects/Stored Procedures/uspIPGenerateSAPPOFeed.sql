CREATE PROCEDURE [dbo].[uspIPGenerateSAPPOFeed]
	@strContractWithSeqNo NVARCHAR(MAX),
	@intUserId int
AS
BEGIN TRY

Declare @strContractNo nvarchar(500),
		@strSeqNo	nvarchar(500),
		@intCharIndex int,
		@id NVARCHAR(50),
		@index INT,
		@intContractHeaderId int,
		@intContractDetailId int,
		@strCommodityCode Nvarchar(50),
		@intContractFeedId int,
		@strErrMsg nvarchar(max)

Declare @tblSeq AS table
(
	intSeq int
)

If ISNULL(@strContractWithSeqNo,'')=''
	RaisError('Invalid Contract No.',16,1)

Set @intCharIndex=CHARINDEX('/',@strContractWithSeqNo)
Select @strContractNo=LTRIM(RTRIM(LEFT(@strContractWithSeqNo, @intCharIndex-1)))
Select @strSeqNo=LTRIM(RTRIM(RIGHT(@strContractWithSeqNo , (LEN(@strContractWithSeqNo) - @intCharIndex))))

--Get the Comma Separated Seq into a table
SET @index = CharIndex(',',@strSeqNo)
WHILE @index > 0
BEGIN
        SET @id = SUBSTRING(@strSeqNo,1,@index-1)
        SET @strSeqNo = SUBSTRING(@strSeqNo,@index+1,LEN(@strSeqNo)-@index)

        INSERT INTO @tblSeq Select @id
        SET @index = CharIndex(',',@strSeqNo)
END
SET @id=@strSeqNo
INSERT INTO @tblSeq Select @id

Select @intContractHeaderId=intContractHeaderId from tblCTContractHeader Where strContractNumber=@strContractNo

If @intContractHeaderId is null
	RaisError('Contract No does not exist.',16,1)

Select @intContractDetailId=cd.intContractDetailId,@strCommodityCode=c.strCommodityCode 
from tblCTContractDetail cd join tblICItem i on cd.intItemId=i.intItemId
join tblICCommodity c on i.intCommodityId=c.intCommodityId
Where cd.intContractHeaderId=@intContractHeaderId AND intContractSeq=(Select TOP 1 intSeq from @tblSeq)

If @intContractDetailId is null
	RaisError('Contract Seq does not exist.',16,1)

If UPPER(@strCommodityCode)='COFFEE'
Begin
	Select TOP 1 @intContractFeedId=intContractFeedId from tblCTContractFeed Where intContractDetailId=@intContractDetailId 
			AND UPPER(strRowState)='ADDED' AND strFeedStatus='Ack Rcvd' AND strMessage<>'Success'
			Order by intContractFeedId

	If @intContractFeedId>0
	Begin
		Begin Transaction

		Delete From tblCTContractFeed Where intContractHeaderId=@intContractHeaderId AND intContractDetailId=@intContractDetailId

		Exec uspCTContractApproved @intContractHeaderId,@intUserId,@intContractDetailId,0

		Commit Transaction
	End
	Else
		RaisError('Unable to send feed.',16,1)
End
Else
Begin
	Select TOP 1 @intContractFeedId=intContractFeedId from tblCTContractFeed Where intContractHeaderId=@intContractHeaderId
			AND UPPER(strRowState)='ADDED' AND strFeedStatus='Ack Rcvd' AND strMessage<>'Success'
			Order by intContractFeedId

	If @intContractFeedId>0
	Begin
		Begin Transaction

		Delete From tblCTContractFeed Where intContractHeaderId=@intContractHeaderId

		Exec uspCTContractApproved @intContractHeaderId,@intUserId,null,0

		Commit Transaction
	End
	Else
		RaisError('Unable to send feed.',16,1)
End

END TRY

BEGIN CATCH
 
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @strErrMsg = ERROR_MESSAGE()  
 RAISERROR(@strErrMsg, 16, 1, 'WITH NOWAIT')  

END CATCH
