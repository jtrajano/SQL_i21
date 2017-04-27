CREATE PROCEDURE [dbo].[uspSMTransactionCheckIfRequiredApproval]
  @type NVARCHAR(250),
  @transactionEntityId INT,
  @currentUserEntityId INT,
  @locationId INT,
  @amount DECIMAL,
  @requireApproval BIT OUTPUT
AS
BEGIN
	DECLARE @countValue INT = 0
	
	IF @countValue = 0 --FIRST LEVEL - ENTITY
	BEGIN
		select @countValue=count(*) from tblEMEntityRequireApprovalFor em
			inner join tblSMScreen screen on screen.intScreenId = em.intScreenId
			inner join tblSMApprovalList c on c.intApprovalListId = em.intApprovalListId
			inner join tblSMApprovalListUserSecurity d on d.intApprovalListId = c.intApprovalListId
		where 
			screen.strNamespace = @type and
			em.intEntityId = @currentUserEntityId and (
				(d.dblAmountLessThanEqual = 0 and d.dblAmountOver = 0) or
				(d.dblAmountLessThanEqual = 0 and (d.dblAmountOver > 0 and @amount > d.dblAmountOver)) or
				((d.dblAmountLessThanEqual > 0 and @amount <= d.dblAmountLessThanEqual) and d.dblAmountOver = 0) or
				(d.dblAmountLessThanEqual > 0 and d.dblAmountOver > 0 and @amount <= d.dblAmountLessThanEqual and @amount > d.dblAmountOver)
			)
	END

	IF @countValue = 0 --SECOND LEVEL - COMPANY LOCATION
	BEGIN
		select @countValue=count(*) from tblSMCompanyLocationRequireApprovalFor smLocation
			inner join tblSMScreen screen on screen.intScreenId = smLocation.intScreenId
			inner join tblSMApprovalList c on c.intApprovalListId = smLocation.intApprovalListId
			inner join tblSMApprovalListUserSecurity d on d.intApprovalListId = c.intApprovalListId
		where
			screen.strNamespace = @type and
			smLocation.intCompanyLocationId = @locationId and (
				(d.dblAmountLessThanEqual = 0 and d.dblAmountOver = 0) or
				(d.dblAmountLessThanEqual = 0 and (d.dblAmountOver > 0 and @amount > d.dblAmountOver)) or
				((d.dblAmountLessThanEqual > 0 and @amount <= d.dblAmountLessThanEqual) and d.dblAmountOver = 0) or
				(d.dblAmountLessThanEqual > 0 and d.dblAmountOver > 0 and @amount <= d.dblAmountLessThanEqual and @amount > d.dblAmountOver)
			)
	END

	IF @countValue = 0 --THIRD LEVEL - USER
	BEGIN
		select @countValue=count(*) from tblSMUserSecurityRequireApprovalFor smUser
			inner join tblSMScreen screen on screen.intScreenId = smUser.intScreenId
			inner join tblSMApprovalList c on c.intApprovalListId = smUser.intApprovalListId
			inner join tblSMApprovalListUserSecurity d on d.intApprovalListId = c.intApprovalListId
		where
			screen.strNamespace = @type and
			smUser.intEntityUserSecurityId = @currentUserEntityId and (
				(d.intEntityUserSecurityId IS NULL OR d.intEntityUserSecurityId <> @currentUserEntityId) and 
				(d.dblAmountLessThanEqual = 0 and d.dblAmountOver = 0) or
				(d.dblAmountLessThanEqual = 0 and (d.dblAmountOver > 0 and @amount > d.dblAmountOver)) or
				((d.dblAmountLessThanEqual > 0 and @amount <= d.dblAmountLessThanEqual) and d.dblAmountOver = 0) or
				(d.dblAmountLessThanEqual > 0 and d.dblAmountOver > 0 and @amount <= d.dblAmountLessThanEqual and @amount > d.dblAmountOver)
			)
	END

	IF @countValue > 0
		BEGIN
			SELECT @requireApproval = 1
		END
	
	RETURN @requireApproval
END

