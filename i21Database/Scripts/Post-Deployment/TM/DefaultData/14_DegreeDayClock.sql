print N'BEGIN Creating default maximum daily degree day.'
GO
	declare @maxJan numeric(18,6) = 150.00;
	declare @maxFeb numeric(18,6) = 150.00;
	declare @maxMar numeric(18,6) = 150.00;
	declare @maxApr numeric(18,6) = 150.00;
	declare @maxMay numeric(18,6) = 50.00;
	declare @maxJun numeric(18,6) = 50.00;
	declare @maxJul numeric(18,6) = 50.00;
	declare @maxAug numeric(18,6) = 50.00;
	declare @maxSep numeric(18,6) = 150.00;
	declare @maxOct numeric(18,6) = 150.00;
	declare @maxNov numeric(18,6) = 150.00;
	declare @maxDec numeric(18,6) = 150.00;

	update tblTMClock set dblJanuaryDailyMaximum = @maxJan where dblJanuaryDailyMaximum is null or dblJanuaryDailyMaximum = 0.00;
	update tblTMClock set dblFebruaryDailyMaximum = @maxFeb where dblFebruaryDailyMaximum is null or dblFebruaryDailyMaximum = 0.00;
	update tblTMClock set dblMarchDailyMaximum = @maxMar where dblMarchDailyMaximum is null or dblMarchDailyMaximum = 0.00;
	update tblTMClock set dblAprilDailyMaximum = @maxApr where dblAprilDailyMaximum is null or dblAprilDailyMaximum = 0.00;
	update tblTMClock set dblMayDailyMaximum = @maxMay where dblMayDailyMaximum is null or dblMayDailyMaximum = 0.00;
	update tblTMClock set dblJuneDailyMaximum = @maxJun where dblJuneDailyMaximum is null or dblJuneDailyMaximum = 0.00;
	update tblTMClock set dblJulyDailyMaximum = @maxJul where dblJulyDailyMaximum is null or dblJulyDailyMaximum = 0.00;
	update tblTMClock set dblAugustDailyMaximum = @maxAug where dblAugustDailyMaximum is null or dblAugustDailyMaximum = 0.00;
	update tblTMClock set dblSeptemberDailyMaximum = @maxSep where dblSeptemberDailyMaximum is null or dblSeptemberDailyMaximum = 0.00;
	update tblTMClock set dblOctoberDailyMaximum = @maxOct where dblOctoberDailyMaximum is null or dblOctoberDailyMaximum = 0.00;
	update tblTMClock set dblNovemberDailyMaximum = @maxNov where dblNovemberDailyMaximum is null or dblNovemberDailyMaximum = 0.00;
	update tblTMClock set dblDecemberDailyMaximum = @maxDec where dblDecemberDailyMaximum is null or dblDecemberDailyMaximum = 0.00;

GO
print N'END Creating default maximum daily degree day.'
GO