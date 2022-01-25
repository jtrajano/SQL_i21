CREATE PROCEDURE [dbo].[uspSCISBinSearchGetHeader]

as 

begin
	declare @HeaderTable table(
		intId int identity(1,1), 
		strColumnName nvarchar(100)
	)
	insert into @HeaderTable(strColumnName)
	select Item from dbo.fnSplitString('intBinSearchId,intStorageLocationId,strStorageLocationName,strStorageUnitName,strCommodityCode,strItemNo,dblPercentageFull,dblCapacity,dblQuantity,dblSpaceAvailable,strBinType,strBinType2,strBinNotes,strBinNotesColor,strBinNotesBackgroundColor,strComBinNotesColor,strComBinNotesBackgroundColor,dtmTrackingDate',',')

	insert into @HeaderTable(strColumnName)
	select replace(strHeader, ' ', '_')  as strHeader from tblSCISBinDiscountHeader order by intBinDiscountHeaderId asc 


	select * from @HeaderTable
end
