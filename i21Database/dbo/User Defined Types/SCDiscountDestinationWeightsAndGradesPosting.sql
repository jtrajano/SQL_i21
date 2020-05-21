/*
	This is a user-defined table type used in the manual scale ticket distribution for inventory costing stored procedures. 
*/
CREATE TYPE [dbo].[SCDiscountDestinationWeightsAndGradesPosting] AS TABLE
(
	dblGradeReading NUMERIC(18,6) NOT NULL DEFAULT 0
	,strCalcMethod NVARCHAR(3) COLLATE Latin1_General_CI_AS
	,strShrinkWhat NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblShrinkPercent NUMERIC(24,10) 
	,dblDiscountAmount NUMERIC(24,10) 
	,dblDiscountDue NUMERIC(24,10) 
	,dblDiscountPaid NUMERIC(24,10) 
	,ysnGraderAutoEntry BIT NOT NULL DEFAULT 0
	,intDiscountScheduleCodeId INT NOT NULL 
	,intSort INT 
	,strDiscountChargeType NVARCHAR(30)
)