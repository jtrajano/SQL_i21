CREATE view vyuRKOptionStrikeList
AS
SELECT CONVERT(int,ROW_NUMBER() 
        OVER (ORDER BY dblStrike)) AS intRowNum,* from(
SELECT DISTINCT  dblStrike,intOptionMonthId FROM tblRKFutOptTransaction WHERE dblStrike is not null and intInstrumentTypeId=2)t