CREATE PROCEDURE [dbo].[uspNRGetDetailsForInvoice]
@intNoteId int
As
BEGIN

-- Get Invoice List
	DECLARE @intCustomerId int
	SELECT @intCustomerId = intCustomerId FROM dbo.tblNRNote WHERE intNoteId = @intNoteId

	SELECT intInvoiceId 
	, strInvoiceNumber	-- Invoice Number
	,dtmDate			-- Invoice Date
	,(CASE WHEN strTransactionType = 'I' THEN ISNULL((dblAmountDue - dblPayment),0) ELSE 0 END) [dblAmount]
	, I.intCompanyLocationId 
	, CL.strLocationName
	, (CASE WHEN strTransactionType = 'I' THEN 'Invoice' ELSE 'CREDIT MEMO' END) [strType]
	, CAST(0 as bit) [blnChk]
	FROM dbo.tblARInvoice I
	JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = I.intCompanyLocationId
	WHERE I.intCustomerId = @intCustomerId AND strTransactionType in ('I', 'C')

--Get latest Principal
	SELECT top 1 dblPrincipal FROM dbo.tblNRNoteTransaction WHERE intNoteId = @intNoteId ORDER BY intNoteTransId DESC

--Get latest, incremented sreRefNo
	DECLARE @intRefNo int, @intCnt int, @strRefNo nvarchar(20)
	Select @intCnt = COUNT(strRefNo) FROM [dbo].tblNRNoteTransaction where intNoteTransTypeId=1 -- Order by intNoteTransId desc

	IF @intCnt = 0
		SET @strRefNo = 'NX0001'
	ELSE
	BEGIN
		Select top 1 @strRefNo = strRefNo FROM [dbo].tblNRNoteTransaction where intNoteTransTypeId=1  Order by intNoteTransId desc
		--SET @strRefNo = 'NX00024'
		Select @strRefNo = SUBSTRING(@strRefNo, 3,(LEN(@strRefNo) - 2))--FROM [dbo].tblNRNoteTransaction where intNoteTransTypeId=1  Order by intNoteTransId desc
		SET @intRefNo = @strRefNo
		
		select  @strRefNo = 'NX' + REPLICATE('0',4-LEN(@intRefNo+1))  + cast((@intRefNo+1) as nvarchar(5))

	END	

	SELECT @strRefNo [strRefNo] 
	
	Select dtmCreated from dbo.tblNRNote Where intNoteId = @intNoteId
	
	SELECT TOP 1 dtmNoteTranDate FROM dbo.tblNRNoteTransaction WHERE intNoteId = @intNoteId AND intNoteTransTypeId = 3 ORDER BY intNoteTransId DESC
	
END
