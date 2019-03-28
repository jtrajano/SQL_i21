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

	update tblTMClock set dblJanuaryDailyMaximum = @maxJan where dblJanuaryDailyMaximum is null;
	update tblTMClock set dblFebruaryDailyMaximum = @maxFeb where dblFebruaryDailyMaximum is null;
	update tblTMClock set dblMarchDailyMaximum = @maxMar where dblMarchDailyMaximum is null;
	update tblTMClock set dblAprilDailyMaximum = @maxApr where dblAprilDailyMaximum is null;
	update tblTMClock set dblMayDailyMaximum = @maxMay where dblMayDailyMaximum is null;
	update tblTMClock set dblJuneDailyMaximum = @maxJun where dblJuneDailyMaximum is null;
	update tblTMClock set dblJulyDailyMaximum = @maxJul where dblJulyDailyMaximum is null;
	update tblTMClock set dblAugustDailyMaximum = @maxAug where dblAugustDailyMaximum is null;
	update tblTMClock set dblSeptemberDailyMaximum = @maxSep where dblSeptemberDailyMaximum is null;
	update tblTMClock set dblOctoberDailyMaximum = @maxOct where dblOctoberDailyMaximum is null;
	update tblTMClock set dblNovemberDailyMaximum = @maxNov where dblNovemberDailyMaximum is null;
	update tblTMClock set dblDecemberDailyMaximum = @maxDec where dblDecemberDailyMaximum is null;

GO
print N'END Creating default maximum daily degree day.'
GO