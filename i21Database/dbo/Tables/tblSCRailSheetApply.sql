CREATE TABLE [dbo].[tblSCRailSheetApply]
(
	intRailSheetApplyId int not null identity(1,1)  primary key
	,intRailSheetId int not null
	,intApplyType int not null
	,intContractDetailId int null
	,dblUnits numeric(38, 20)
	,dblBasis numeric(38, 20)
	,dblFutures numeric(38, 20)
	,intSort int not null default(1)
	,intConcurrencyId int default(1)

	,constraint fk_tblSCRailSheetApply_tblSCRailSheet_intRailSheetId foreign key (intRailSheetId) references tblSCRailSheet(intRailSheetId)
	,constraint fk_tblSCRailSheetApply_tblCTContractDetail_intContractDetailId foreign key (intContractDetailId) references tblCTContractDetail(intContractDetailId)
)