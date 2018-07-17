PRINT 'CHECKING AP BALANCE'
if not exists(select top 1 1 from tblAPBalance)

begin
	PRINT 'ADDING DEFAULT DATA'
	declare @o1 DECIMAL(18,6)
	declare @o2 NVARCHAR(100)
	exec [uspAPBalance] 1, @o1 output, @o2 output	
	
	declare @p1 DECIMAL(18,6)
	declare @p2 NVARCHAR(100)
	exec uspAPGLBalance 1, @p1 output, @p2 output	
	
	
	INSERT INTO tblAPBalance(dblGLBalance, dblAPBalance, ysnBalance) select null, null, null
			
	UPDATE tblAPBalance SET dblGLBalance = @p1, dblAPBalance = @o1
	UPDATE tblAPBalance SET ysnBalance = case when dblGLBalance = dblAPBalance then 1 else 0 end


end

PRINT 'END CHECKING AP BALANCE'