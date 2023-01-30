﻿CREATE PROCEDURE [dbo].[uspCTUpdateSequenceCostRate]  
	@intContractDetailId int,  
	@intUserId int  
AS  
BEGIN TRY  

	declare  
		@ErrMsg nvarchar(max)  
		,@intDaysForFinance int
		,@dblInterestRate numeric(38,20)  
		,@intFinanceCostId int  
		,@dblCalculatedRate numeric(38,20) 
		,@principal numeric(38,20) 
		,@rate numeric(38,20)  
		,@time numeric(38,20);  

	select  
		@intDaysForFinance = ch.intDaysForFinance
		,@dblInterestRate = cd.dblInterestRate  
		,@principal = cd.dblTotalCost
		,@rate = convert(numeric(38,20),isnull(cd.dblInterestRate,0.00)) / 100.00  
		,@time = convert(numeric(38,20),isnull(ch.intDaysForFinance,0.00)) / 365.00  
	from
		tblCTContractDetail cd  
		join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId  
	where
		cd.intContractDetailId = @intContractDetailId;  

	select top 1 @intFinanceCostId = intFinanceCostId from tblCTCompanyPreference;  

	if (@intDaysForFinance is not null and @principal is not null and @dblInterestRate is not null and @intFinanceCostId is not null)  
	begin  
		select @dblCalculatedRate = @principal * @rate * @time;  
		update tblCTContractCost set dblRate = @dblCalculatedRate, dblActualAmount = @dblCalculatedRate where intContractDetailId = @intContractDetailId and intItemId = @intFinanceCostId;  
	end  

END TRY        
BEGIN CATCH         
	SET @ErrMsg = ERROR_MESSAGE()        
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')        
END CATCH