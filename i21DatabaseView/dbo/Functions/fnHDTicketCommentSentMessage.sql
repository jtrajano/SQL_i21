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
	set @message =  'Sent: Just now';
	end
	if (@minDiff = 1)
	begin
	set @message =  'Sent: A minute ago';
	end
	if (@minDiff > 1 and @minDiff < 60)
	begin
	set @message =  'Sent: ' + convert(nvarchar(2),@minDiff) + ' minutes ago';
	end
	if (@minDiff = 60)
	begin
	set @message =  'Sent: An hour ago';
	end
	if (@minDiff > 60 and @minDiff < 120)
	begin
	set @message =  'Sent: More than an hour ago';
	end
	set @hourDiff = cast((@minDiff/60)as int);
	if (@hourDiff > 1 and @hourDiff < 24)
	begin
	set @message =  'Sent: ' + convert(nvarchar(2), @hourDiff) + ' hours ago';
	end
	if (@hourDiff = 24)
	begin
	set @message =  'Sent: A day ago';
	end
	if (@hourDiff > 24 and @hourDiff < 48)
	begin
	set @message =  'Sent: More than a day ago';
	end
	set @dayDiff = cast((@hourDiff/24)as int);
	if (@dayDiff > 1 and @dayDiff < 7)
	begin
	set @message =  'Sent: ' + convert(nvarchar(2), @dayDiff) + ' days ago';
	end
	if (@dayDiff = 7)
	begin
	set @message =  'Sent: A week ago';
	end
	if (@dayDiff > 7 and @dayDiff < 14)
	begin
	set @message =  'Sent: More than a week ago';
	end
	set @weekDiff = cast((@dayDiff/7)as int);
	if (@weekDiff > 1 and @weekDiff < 4)
	begin
	set @message =  'Sent: ' + convert(nvarchar(2), @weekDiff) + ' weeks ago';
	end
	if (@weekDiff = 4)
	begin
	set @message =  'Sent: A month ago';
	end
	if (@weekDiff > 4 and @weekDiff < 8)
	begin
	set @message =  'Sent: More than a month ago';
	end
	set @monthDiff = cast((@weekDiff/4)as int);
	if (@monthDiff > 1 and @monthDiff < 12)
	begin
	set @message =  'Sent: ' + convert(nvarchar(2), @monthDiff) + ' months ago';
	end
	if (@monthDiff = 12)
	begin
	set @message =  'Sent: A year ago';
	end
	if (@monthDiff > 12 and @monthDiff < 24)
	begin
	set @message =  'Sent: More than a year ago';
	end
	set @yearDiff = cast((@monthDiff/12)as int);
	if (@yearDiff > 1)
	begin
	set @message =  'Sent: ' + convert(nvarchar(2), @yearDiff) + ' years ago';
	end

	RETURN @message

END