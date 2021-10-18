CREATE PROCEDURE [dbo].[uspSCISBinSearchGetHeader]

as 

begin
	declare @HeaderTable table(
		intId int identity(1,1), 
		strColumnName nvarchar(100)
	)
	insert into @HeaderTable(strColumnName)
	select Item from dbo.fnSplitString('intBinSearchId,intStorageLocationId,strStorageLocationName,strCommodityCode,dblPercentageFull,dblAvailable,strBinType,strBinType2,strBinNotes,strBinNotesColor,strBinNotesBackgroundColor',',')

	insert into @HeaderTable(strColumnName)
	select strHeader from tblSCISBinDiscountHeader order by intBinDiscountHeaderId asc 


	select * from @HeaderTable
end
