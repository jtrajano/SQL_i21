CREATE PROCEDURE [dbo].[uspCTGetAmendmentHistory]
	 @intContractHeaderId int
	,@ysnCount				BIT				=  0
	,@strStart				NVARCHAR(10)	= '0'
	,@strLimit				NVARCHAR(10)	= '100'
	,@strFilterCriteria		NVARCHAR(MAX)	= ' 1 = 1'
	,@strSortField			NVARCHAR(MAX)	= 'intSequenceAmendmentLogId'
	,@strSortDirection		NVARCHAR(5)		= 'ASC'
AS
SET NOCOUNT ON

BEGIN TRY
	DECLARE  @SQL		NVARCHAR(MAX)
			,@ErrMsg	NVARCHAR(MAX)

	IF @strFilterCriteria = ''
		SET @strFilterCriteria = ' 1 = 1'
    
	WHILE @strFilterCriteria like '%OR OR%'
	BEGIN
		SET @strFilterCriteria = REPLACE(@strFilterCriteria,'OR OR','OR')
	END

	SELECT @SQL='SELECT * FROM vyuCTAmendmentHistory WHERE intContractHeaderId = '+LTRIM(@intContractHeaderId)+' AND '+@strFilterCriteria

	EXEC sp_executesql @SQL

END TRY

BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH

