CREATE VIEW [dbo].[vyuPRGetPayGroupEmployeeToProcess]
AS
	SELECT 
		 intEntityEmployeeId = PayGroupDetail.intEntityEmployeeId
		,strEmployeeId		 = Employee.strEmployeeId
		,strFirstName		 = ISNULL(Employee.strFirstName, '')
		,strLastName		 = ISNULL(Employee.strLastName, '')
		,intPayGroupIds		 = CONVERT(NVARCHAR(20), PayGroup.intPayGroupId)
		,strPayGroupIds		 = PayGroup.strPayGroup
		,dtmPayDate			 = PayGroup.dtmPayDate
		,dtmBeginDate		 = PayGroup.dtmBeginDate
		,dtmEndDate			 = PayGroup.dtmEndDate
		,intBankAccountId    = PayGroup.intBankAccountId
		,dblHours			 = SUM(ISNULL(PayGroupDetail.dblHoursToProcess, 0))
		,dblTotal			 = SUM(ISNULL(PayGroupDetail.dblTotal, 0))
	 FROM tblPRPayGroupDetail PayGroupDetail
		INNER JOIN tblPREmployee Employee
	ON PayGroupDetail.intEntityEmployeeId = Employee.intEntityId
		INNER JOIN tblPRPayGroup PayGroup
	ON PayGroup.intPayGroupId = PayGroupDetail.intPayGroupId
	WHERE PayGroup.dtmBeginDate <= COALESCE(PayGroupDetail.dtmDateFrom, PayGroup.dtmBeginDate) AND
		  PayGroup.dtmEndDate  >= COALESCE(PayGroupDetail.dtmDateFrom, PayGroup.dtmBeginDate) AND
		  Employee.ysnActive = CONVERT(BIT, 1) AND
		  ISNULL(PayGroupDetail.dblTotal, 0) <> 0
	GROUP BY PayGroupDetail.intEntityEmployeeId
			,Employee.strEmployeeId
			,Employee.strFirstName	
			,Employee.strLastName
			,PayGroup.dtmPayDate
			,PayGroup.dtmBeginDate
			,PayGroup.dtmEndDate
			,PayGroup.intBankAccountId
			,PayGroup.intPayGroupId
			,PayGroup.strPayGroup
GO