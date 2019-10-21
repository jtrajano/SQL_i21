CREATE FUNCTION [dbo].[fnEMBreakLine]
(
	@string			nvarchar(max),
	@len			int = 80
)
RETURNS nvarchar(max)
AS
BEGIN
	declare @a nvarchar(max)
	declare @b nvarchar(80)
	declare @c nvarchar(max)
	declare @d int
	declare @e int
	declare @f int

	set @a = @string
	set @d = @len
	set @e = @len
	set @f = 1
	set @c = ''

	set @b = '-'
	while(@b <> '')
	begin
	
		set @b = SUBSTRING(@a, (@d - @e) + @f , @d)	
		--select @b
		set @d = @d + @e

		if @b <> ''
		begin
			set @c = @c + @b  + char(10) + char(13)  
		end
		
	end



	return @c
END
