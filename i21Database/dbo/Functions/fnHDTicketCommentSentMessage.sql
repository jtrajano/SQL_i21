CREATE FUNCTION [dbo].[fnHDTicketCommentSentMessage](@dateFrom datetime, @dateTo datetime)
RETURNS nvarchar(max)
AS
BEGIN

	declare @message nvarchar(max);
	declare @minDiff as int;
	declare @hourDiff as int;
	declare @dayDiff as int;
	declare @weekDiff as int;
	declare @monthDiff as int;
	declare @yearDiff as int;

	set @minDiff = (select DATEDIFF(minute,@dateFrom,@dateTo));

	if (@minDiff < 1)
	begin
	set @message =  'Sent: Just now' COLLATE Latin1_General_CI_AS;
	end
	if (@minDiff = 1)
	begin
	set @message =  'Sent: A minute ago' COLLATE Latin1_General_CI_AS;
	end
	if (@minDiff > 1 and @minDiff < 60)
	begin
	set @message =  'Sent: ' + convert(nvarchar(2),@minDiff) + ' minutes ago' COLLATE Latin1_General_CI_AS;
	end
	if (@minDiff = 60)
	begin
	set @message =  'Sent: An hour ago' COLLATE Latin1_General_CI_AS;
	end
	if (@minDiff > 60 and @minDiff < 120)
	begin
	set @message =  'Sent: More than an hour ago' COLLATE Latin1_General_CI_AS;
	end
	set @hourDiff = cast((@minDiff/60)as int);
	if (@hourDiff > 1 and @hourDiff < 24)
	begin
	set @message =  'Sent: ' + convert(nvarchar(2), @hourDiff) + ' hours ago' COLLATE Latin1_General_CI_AS;
	end
	if (@hourDiff = 24)
	begin
	set @message =  'Sent: A day ago' COLLATE Latin1_General_CI_AS;
	end
	if (@hourDiff > 24 and @hourDiff < 48)
	begin
	set @message =  'Sent: More than a day ago' COLLATE Latin1_General_CI_AS;
	end
	set @dayDiff = cast((@hourDiff/24)as int);
	if (@dayDiff > 1 and @dayDiff < 7)
	begin
	set @message =  'Sent: ' + convert(nvarchar(2), @dayDiff) + ' days ago' COLLATE Latin1_General_CI_AS;
	end
	if (@dayDiff = 7)
	begin
	set @message =  'Sent: A week ago' COLLATE Latin1_General_CI_AS;
	end
	if (@dayDiff > 7 and @dayDiff < 14)
	begin
	set @message =  'Sent: More than a week ago' COLLATE Latin1_General_CI_AS;
	end
	set @weekDiff = cast((@dayDiff/7)as int);
	if (@weekDiff > 1 and @weekDiff < 4)
	begin
	set @message =  'Sent: ' + convert(nvarchar(2), @weekDiff) + ' weeks ago' COLLATE Latin1_General_CI_AS;
	end
	if (@weekDiff = 4)
	begin
	set @message =  'Sent: A month ago' COLLATE Latin1_General_CI_AS;
	end
	if (@weekDiff > 4 and @weekDiff < 8)
	begin
	set @message =  'Sent: More than a month ago' COLLATE Latin1_General_CI_AS;
	end
	set @monthDiff = cast((@weekDiff/4)as int);
	if (@monthDiff > 1 and @monthDiff < 12)
	begin
	set @message =  'Sent: ' + convert(nvarchar(2), @monthDiff) + ' months ago' COLLATE Latin1_General_CI_AS;
	end
	if (@monthDiff = 12)
	begin
	set @message =  'Sent: A year ago' COLLATE Latin1_General_CI_AS;
	end
	if (@monthDiff > 12 and @monthDiff < 24)
	begin
	set @message =  'Sent: More than a year ago'COLLATE Latin1_General_CI_AS;
	end
	set @yearDiff = cast((@monthDiff/12)as int);
	if (@yearDiff > 1)
	begin
	set @message =  'Sent: ' + convert(nvarchar(2), @yearDiff) + ' years ago' COLLATE Latin1_General_CI_AS;
	end

	RETURN @message COLLATE Latin1_General_CI_AS

END

GO