IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND  TABLE_NAME = 'tblGRReadingRanges')
BEGIN

PRINT 'Start inserting fixed data in tblGRReadingRanges'

IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '0-0.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('0-0.9',0,0.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '1-1.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('1-1.9',1,1.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '2-2.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('2-2.9',2,2.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '3-3.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('3-3.9',3,3.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '4-4.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('4-4.9',4,4.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '5-5.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('5-5.9',5,5.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '6-6.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('6-6.9',6,6.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '7-7.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('7-7.9',7,7.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '8-8.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('8-8.9',8,8.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '9-9.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('9-9.9',9,9.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '10-10.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('10-10.9',10,10.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '11-11.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('11-11.9',11,11.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '12-12.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('12-12.9',12,12.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '13-13.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('13-13.9',13,13.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '14-14.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('14-14.9',14,14.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '15-15.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('15-15.9',15,15.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '16-16.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('16-16.9',16,16.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '17-17.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('17-17.9',17,17.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '18-18.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('18-18.9',18,18.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '19-19.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('19-19.9',19,19.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '20-20.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('20-20.9',20,20.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '21-21.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('21-21.9',21,21.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '22-22.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('22-22.9',22,22.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '23-23.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('23-23.9',23,23.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '24-24.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('24-24.9',24,24.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '25-25.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('25-25.9',25,25.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '26-26.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('26-26.9',26,26.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '27-27.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('27-27.9',27,27.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '28-28.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('28-28.9',28,28.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '29-29.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('29-29.9',29,29.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '30-30.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('30-30.9',30,30.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '31-31.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('31-31.9',31,31.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '32-32.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('32-32.9',32,32.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '33-33.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('33-33.9',33,33.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '34-34.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('34-34.9',34,34.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '35-35.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('35-35.9',35,35.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '36-36.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('36-36.9',36,36.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '37-37.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('37-37.9',37,37.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '38-38.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('38-38.9',38,38.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '39-39.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('39-39.9',39,39.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '40-40.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('40-40.9',40,40.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '41-41.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('41-41.9',41,41.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '42-42.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('42-42.9',42,42.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '43-43.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('43-43.9',43,43.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '44-44.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('44-44.9',44,44.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '45-45.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('45-45.9',45,45.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '46-46.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('46-46.9',46,46.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '47-47.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('47-47.9',47,47.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '48-48.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('48-48.9',48,48.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '49-49.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('49-49.9',49,49.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '50-50.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('50-50.9',50,50.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '51-51.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('51-51.9',51,51.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '52-52.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('52-52.9',52,52.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '53-53.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('53-53.9',53,53.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '54-54.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('54-54.9',54,54.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '55-55.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('55-55.9',55,55.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '56-56.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('56-56.9',56,56.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '57-57.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('57-57.9',57,57.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '58-58.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('58-58.9',58,58.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '59-59.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('59-59.9',59,59.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '60-60.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('60-60.9',60,60.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '61-61.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('61-61.9',61,61.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '62-62.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('62-62.9',62,62.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '63-63.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('63-63.9',63,63.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '64-64.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('64-64.9',64,64.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '65-65.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('65-65.9',65,65.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '66-66.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('66-66.9',66,66.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '67-67.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('67-67.9',67,67.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '68-68.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('68-68.9',68,68.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '69-69.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('69-69.9',69,69.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '70-70.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('70-70.9',70,70.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '71-71.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('71-71.9',71,71.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '72-72.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('72-72.9',72,72.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '73-73.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('73-73.9',73,73.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '74-74.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('74-74.9',74,74.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '75-75.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('75-75.9',75,75.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '76-76.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('76-76.9',76,76.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '77-77.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('77-77.9',77,77.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '78-78.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('78-78.9',78,78.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '79-79.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('79-79.9',79,79.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '80-80.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('80-80.9',80,80.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '81-81.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('81-81.9',81,81.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '82-82.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('82-82.9',82,82.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '83-83.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('83-83.9',83,83.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '84-84.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('84-84.9',84,84.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '85-85.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('85-85.9',85,85.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '86-86.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('86-86.9',86,86.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '87-87.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('87-87.9',87,87.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '88-88.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('88-88.9',88,88.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '89-89.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('89-89.9',89,89.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '90-90.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('90-90.9',90,90.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '91-91.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('91-91.9',91,91.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '92-92.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('92-92.9',92,92.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '93-93.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('93-93.9',93,93.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '94-94.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('94-94.9',94,94.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '95-95.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('95-95.9',95,95.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '96-96.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('96-96.9',96,96.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '97-97.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('97-97.9',97,97.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '98-98.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('98-98.9',98,98.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '99-99.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('99-99.9',99,99.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '100-100.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('100-100.9',100,100.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '101-101.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('101-101.9',101,101.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '102-102.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('102-102.9',102,102.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '103-103.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('103-103.9',103,103.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '104-104.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('104-104.9',104,104.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '105-105.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('105-105.9',105,105.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '106-106.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('106-106.9',106,106.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '107-107.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('107-107.9',107,107.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '108-108.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('108-108.9',108,108.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '109-109.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('109-109.9',109,109.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '110-110.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('110-110.9',110,110.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '111-111.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('111-111.9',111,111.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '112-112.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('112-112.9',112,112.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '113-113.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('113-113.9',113,113.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '114-114.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('114-114.9',114,114.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '115-115.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('115-115.9',115,115.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '116-116.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('116-116.9',116,116.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '117-117.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('117-117.9',117,117.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '118-118.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('118-118.9',118,118.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '119-119.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('119-119.9',119,119.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '120-120.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('120-120.9',120,120.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '121-121.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('121-121.9',121,121.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '122-122.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('122-122.9',122,122.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '123-123.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('123-123.9',123,123.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '124-124.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('124-124.9',124,124.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '125-125.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('125-125.9',125,125.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '126-126.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('126-126.9',126,126.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '127-127.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('127-127.9',127,127.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '128-128.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('128-128.9',128,128.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '129-129.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('129-129.9',129,129.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '130-130.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('130-130.9',130,130.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '131-131.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('131-131.9',131,131.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '132-132.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('132-132.9',132,132.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '133-133.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('133-133.9',133,133.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '134-134.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('134-134.9',134,134.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '135-135.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('135-135.9',135,135.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '136-136.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('136-136.9',136,136.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '137-137.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('137-137.9',137,137.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '138-138.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('138-138.9',138,138.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '139-139.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('139-139.9',139,139.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '140-140.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('140-140.9',140,140.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '141-141.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('141-141.9',141,141.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '142-142.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('142-142.9',142,142.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '143-143.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('143-143.9',143,143.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '144-144.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('144-144.9',144,144.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '145-145.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('145-145.9',145,145.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '146-146.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('146-146.9',146,146.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '147-147.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('147-147.9',147,147.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '148-148.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('148-148.9',148,148.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '149-149.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('149-149.9',149,149.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '150-150.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('150-150.9',150,150.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '151-151.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('151-151.9',151,151.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '152-152.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('152-152.9',152,152.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '153-153.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('153-153.9',153,153.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '154-154.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('154-154.9',154,154.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '155-155.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('155-155.9',155,155.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '156-156.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('156-156.9',156,156.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '157-157.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('157-157.9',157,157.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '158-158.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('158-158.9',158,158.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '159-159.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('159-159.9',159,159.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '160-160.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('160-160.9',160,160.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '161-161.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('161-161.9',161,161.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '162-162.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('162-162.9',162,162.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '163-163.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('163-163.9',163,163.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '164-164.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('164-164.9',164,164.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '165-165.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('165-165.9',165,165.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '166-166.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('166-166.9',166,166.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '167-167.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('167-167.9',167,167.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '168-168.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('168-168.9',168,168.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '169-169.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('169-169.9',169,169.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '170-170.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('170-170.9',170,170.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '171-171.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('171-171.9',171,171.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '172-172.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('172-172.9',172,172.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '173-173.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('173-173.9',173,173.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '174-174.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('174-174.9',174,174.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '175-175.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('175-175.9',175,175.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '176-176.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('176-176.9',176,176.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '177-177.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('177-177.9',177,177.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '178-178.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('178-178.9',178,178.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '179-179.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('179-179.9',179,179.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '180-180.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('180-180.9',180,180.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '181-181.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('181-181.9',181,181.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '182-182.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('182-182.9',182,182.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '183-183.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('183-183.9',183,183.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '184-184.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('184-184.9',184,184.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '185-185.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('185-185.9',185,185.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '186-186.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('186-186.9',186,186.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '187-187.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('187-187.9',187,187.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '188-188.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('188-188.9',188,188.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '189-189.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('189-189.9',189,189.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '190-190.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('190-190.9',190,190.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '191-191.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('191-191.9',191,191.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '192-192.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('192-192.9',192,192.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '193-193.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('193-193.9',193,193.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '194-194.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('194-194.9',194,194.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '195-195.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('195-195.9',195,195.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '196-196.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('196-196.9',196,196.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '197-197.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('197-197.9',197,197.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '198-198.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('198-198.9',198,198.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '199-199.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('199-199.9',199,199.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '200-200.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('200-200.9',200,200.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '201-201.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('201-201.9',201,201.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '202-202.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('202-202.9',202,202.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '203-203.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('203-203.9',203,203.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '204-204.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('204-204.9',204,204.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '205-205.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('205-205.9',205,205.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '206-206.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('206-206.9',206,206.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '207-207.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('207-207.9',207,207.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '208-208.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('208-208.9',208,208.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '209-209.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('209-209.9',209,209.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '210-210.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('210-210.9',210,210.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '211-211.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('211-211.9',211,211.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '212-212.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('212-212.9',212,212.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '213-213.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('213-213.9',213,213.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '214-214.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('214-214.9',214,214.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '215-215.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('215-215.9',215,215.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '216-216.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('216-216.9',216,216.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '217-217.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('217-217.9',217,217.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '218-218.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('218-218.9',218,218.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '219-219.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('219-219.9',219,219.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '220-220.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('220-220.9',220,220.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '221-221.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('221-221.9',221,221.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '222-222.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('222-222.9',222,222.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '223-223.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('223-223.9',223,223.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '224-224.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('224-224.9',224,224.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '225-225.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('225-225.9',225,225.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '226-226.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('226-226.9',226,226.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '227-227.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('227-227.9',227,227.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '228-228.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('228-228.9',228,228.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '229-229.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('229-229.9',229,229.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '230-230.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('230-230.9',230,230.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '231-231.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('231-231.9',231,231.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '232-232.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('232-232.9',232,232.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '233-233.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('233-233.9',233,233.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '234-234.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('234-234.9',234,234.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '235-235.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('235-235.9',235,235.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '236-236.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('236-236.9',236,236.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '237-237.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('237-237.9',237,237.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '238-238.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('238-238.9',238,238.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '239-239.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('239-239.9',239,239.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '240-240.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('240-240.9',240,240.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '241-241.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('241-241.9',241,241.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '242-242.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('242-242.9',242,242.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '243-243.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('243-243.9',243,243.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '244-244.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('244-244.9',244,244.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '245-245.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('245-245.9',245,245.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '246-246.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('246-246.9',246,246.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '247-247.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('247-247.9',247,247.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '248-248.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('248-248.9',248,248.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '249-249.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('249-249.9',249,249.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '250-250.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('250-250.9',250,250.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '251-251.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('251-251.9',251,251.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '252-252.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('252-252.9',252,252.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '253-253.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('253-253.9',253,253.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '254-254.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('254-254.9',254,254.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '255-255.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('255-255.9',255,255.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '256-256.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('256-256.9',256,256.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '257-257.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('257-257.9',257,257.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '258-258.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('258-258.9',258,258.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '259-259.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('259-259.9',259,259.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '260-260.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('260-260.9',260,260.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '261-261.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('261-261.9',261,261.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '262-262.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('262-262.9',262,262.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '263-263.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('263-263.9',263,263.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '264-264.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('264-264.9',264,264.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '265-265.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('265-265.9',265,265.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '266-266.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('266-266.9',266,266.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '267-267.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('267-267.9',267,267.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '268-268.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('268-268.9',268,268.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '269-269.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('269-269.9',269,269.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '270-270.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('270-270.9',270,270.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '271-271.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('271-271.9',271,271.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '272-272.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('272-272.9',272,272.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '273-273.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('273-273.9',273,273.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '274-274.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('274-274.9',274,274.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '275-275.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('275-275.9',275,275.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '276-276.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('276-276.9',276,276.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '277-277.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('277-277.9',277,277.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '278-278.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('278-278.9',278,278.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '279-279.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('279-279.9',279,279.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '280-280.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('280-280.9',280,280.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '281-281.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('281-281.9',281,281.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '282-282.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('282-282.9',282,282.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '283-283.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('283-283.9',283,283.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '284-284.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('284-284.9',284,284.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '285-285.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('285-285.9',285,285.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '286-286.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('286-286.9',286,286.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '287-287.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('287-287.9',287,287.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '288-288.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('288-288.9',288,288.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '289-289.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('289-289.9',289,289.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '290-290.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('290-290.9',290,290.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '291-291.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('291-291.9',291,291.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '292-292.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('292-292.9',292,292.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '293-293.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('293-293.9',293,293.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '294-294.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('294-294.9',294,294.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '295-295.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('295-295.9',295,295.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '296-296.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('296-296.9',296,296.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '297-297.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('297-297.9',297,297.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '298-298.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('298-298.9',298,298.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '299-299.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('299-299.9',299,299.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '300-300.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('300-300.9',300,300.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '301-301.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('301-301.9',301,301.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '302-302.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('302-302.9',302,302.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '303-303.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('303-303.9',303,303.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '304-304.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('304-304.9',304,304.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '305-305.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('305-305.9',305,305.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '306-306.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('306-306.9',306,306.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '307-307.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('307-307.9',307,307.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '308-308.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('308-308.9',308,308.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '309-309.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('309-309.9',309,309.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '310-310.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('310-310.9',310,310.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '311-311.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('311-311.9',311,311.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '312-312.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('312-312.9',312,312.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '313-313.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('313-313.9',313,313.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '314-314.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('314-314.9',314,314.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '315-315.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('315-315.9',315,315.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '316-316.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('316-316.9',316,316.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '317-317.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('317-317.9',317,317.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '318-318.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('318-318.9',318,318.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '319-319.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('319-319.9',319,319.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '320-320.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('320-320.9',320,320.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '321-321.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('321-321.9',321,321.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '322-322.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('322-322.9',322,322.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '323-323.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('323-323.9',323,323.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '324-324.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('324-324.9',324,324.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '325-325.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('325-325.9',325,325.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '326-326.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('326-326.9',326,326.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '327-327.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('327-327.9',327,327.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '328-328.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('328-328.9',328,328.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '329-329.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('329-329.9',329,329.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '330-330.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('330-330.9',330,330.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '331-331.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('331-331.9',331,331.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '332-332.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('332-332.9',332,332.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '333-333.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('333-333.9',333,333.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '334-334.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('334-334.9',334,334.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '335-335.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('335-335.9',335,335.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '336-336.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('336-336.9',336,336.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '337-337.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('337-337.9',337,337.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '338-338.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('338-338.9',338,338.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '339-339.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('339-339.9',339,339.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '340-340.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('340-340.9',340,340.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '341-341.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('341-341.9',341,341.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '342-342.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('342-342.9',342,342.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '343-343.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('343-343.9',343,343.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '344-344.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('344-344.9',344,344.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '345-345.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('345-345.9',345,345.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '346-346.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('346-346.9',346,346.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '347-347.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('347-347.9',347,347.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '348-348.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('348-348.9',348,348.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '349-349.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('349-349.9',349,349.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '350-350.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('350-350.9',350,350.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '351-351.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('351-351.9',351,351.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '352-352.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('352-352.9',352,352.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '353-353.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('353-353.9',353,353.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '354-354.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('354-354.9',354,354.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '355-355.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('355-355.9',355,355.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '356-356.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('356-356.9',356,356.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '357-357.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('357-357.9',357,357.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '358-358.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('358-358.9',358,358.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '359-359.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('359-359.9',359,359.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '360-360.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('360-360.9',360,360.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '361-361.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('361-361.9',361,361.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '362-362.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('362-362.9',362,362.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '363-363.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('363-363.9',363,363.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '364-364.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('364-364.9',364,364.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '365-365.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('365-365.9',365,365.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '366-366.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('366-366.9',366,366.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '367-367.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('367-367.9',367,367.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '368-368.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('368-368.9',368,368.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '369-369.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('369-369.9',369,369.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '370-370.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('370-370.9',370,370.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '371-371.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('371-371.9',371,371.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '372-372.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('372-372.9',372,372.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '373-373.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('373-373.9',373,373.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '374-374.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('374-374.9',374,374.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '375-375.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('375-375.9',375,375.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '376-376.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('376-376.9',376,376.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '377-377.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('377-377.9',377,377.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '378-378.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('378-378.9',378,378.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '379-379.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('379-379.9',379,379.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '380-380.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('380-380.9',380,380.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '381-381.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('381-381.9',381,381.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '382-382.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('382-382.9',382,382.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '383-383.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('383-383.9',383,383.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '384-384.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('384-384.9',384,384.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '385-385.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('385-385.9',385,385.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '386-386.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('386-386.9',386,386.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '387-387.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('387-387.9',387,387.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '388-388.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('388-388.9',388,388.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '389-389.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('389-389.9',389,389.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '390-390.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('390-390.9',390,390.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '391-391.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('391-391.9',391,391.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '392-392.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('392-392.9',392,392.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '393-393.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('393-393.9',393,393.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '394-394.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('394-394.9',394,394.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '395-395.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('395-395.9',395,395.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '396-396.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('396-396.9',396,396.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '397-397.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('397-397.9',397,397.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '398-398.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('398-398.9',398,398.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '399-399.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('399-399.9',399,399.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '400-400.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('400-400.9',400,400.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '401-401.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('401-401.9',401,401.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '402-402.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('402-402.9',402,402.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '403-403.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('403-403.9',403,403.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '404-404.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('404-404.9',404,404.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '405-405.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('405-405.9',405,405.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '406-406.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('406-406.9',406,406.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '407-407.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('407-407.9',407,407.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '408-408.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('408-408.9',408,408.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '409-409.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('409-409.9',409,409.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '410-410.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('410-410.9',410,410.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '411-411.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('411-411.9',411,411.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '412-412.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('412-412.9',412,412.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '413-413.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('413-413.9',413,413.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '414-414.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('414-414.9',414,414.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '415-415.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('415-415.9',415,415.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '416-416.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('416-416.9',416,416.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '417-417.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('417-417.9',417,417.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '418-418.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('418-418.9',418,418.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '419-419.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('419-419.9',419,419.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '420-420.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('420-420.9',420,420.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '421-421.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('421-421.9',421,421.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '422-422.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('422-422.9',422,422.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '423-423.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('423-423.9',423,423.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '424-424.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('424-424.9',424,424.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '425-425.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('425-425.9',425,425.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '426-426.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('426-426.9',426,426.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '427-427.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('427-427.9',427,427.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '428-428.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('428-428.9',428,428.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '429-429.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('429-429.9',429,429.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '430-430.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('430-430.9',430,430.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '431-431.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('431-431.9',431,431.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '432-432.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('432-432.9',432,432.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '433-433.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('433-433.9',433,433.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '434-434.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('434-434.9',434,434.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '435-435.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('435-435.9',435,435.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '436-436.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('436-436.9',436,436.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '437-437.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('437-437.9',437,437.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '438-438.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('438-438.9',438,438.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '439-439.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('439-439.9',439,439.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '440-440.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('440-440.9',440,440.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '441-441.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('441-441.9',441,441.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '442-442.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('442-442.9',442,442.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '443-443.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('443-443.9',443,443.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '444-444.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('444-444.9',444,444.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '445-445.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('445-445.9',445,445.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '446-446.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('446-446.9',446,446.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '447-447.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('447-447.9',447,447.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '448-448.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('448-448.9',448,448.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '449-449.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('449-449.9',449,449.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '450-450.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('450-450.9',450,450.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '451-451.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('451-451.9',451,451.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '452-452.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('452-452.9',452,452.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '453-453.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('453-453.9',453,453.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '454-454.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('454-454.9',454,454.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '455-455.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('455-455.9',455,455.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '456-456.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('456-456.9',456,456.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '457-457.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('457-457.9',457,457.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '458-458.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('458-458.9',458,458.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '459-459.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('459-459.9',459,459.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '460-460.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('460-460.9',460,460.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '461-461.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('461-461.9',461,461.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '462-462.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('462-462.9',462,462.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '463-463.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('463-463.9',463,463.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '464-464.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('464-464.9',464,464.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '465-465.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('465-465.9',465,465.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '466-466.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('466-466.9',466,466.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '467-467.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('467-467.9',467,467.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '468-468.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('468-468.9',468,468.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '469-469.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('469-469.9',469,469.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '470-470.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('470-470.9',470,470.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '471-471.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('471-471.9',471,471.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '472-472.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('472-472.9',472,472.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '473-473.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('473-473.9',473,473.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '474-474.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('474-474.9',474,474.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '475-475.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('475-475.9',475,475.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '476-476.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('476-476.9',476,476.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '477-477.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('477-477.9',477,477.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '478-478.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('478-478.9',478,478.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '479-479.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('479-479.9',479,479.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '480-480.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('480-480.9',480,480.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '481-481.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('481-481.9',481,481.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '482-482.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('482-482.9',482,482.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '483-483.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('483-483.9',483,483.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '484-484.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('484-484.9',484,484.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '485-485.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('485-485.9',485,485.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '486-486.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('486-486.9',486,486.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '487-487.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('487-487.9',487,487.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '488-488.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('488-488.9',488,488.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '489-489.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('489-489.9',489,489.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '490-490.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('490-490.9',490,490.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '491-491.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('491-491.9',491,491.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '492-492.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('492-492.9',492,492.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '493-493.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('493-493.9',493,493.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '494-494.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('494-494.9',494,494.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '495-495.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('495-495.9',495,495.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '496-496.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('496-496.9',496,496.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '497-497.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('497-497.9',497,497.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '498-498.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('498-498.9',498,498.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '499-499.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('499-499.9',499,499.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '500-500.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('500-500.9',500,500.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '501-501.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('501-501.9',501,501.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '502-502.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('502-502.9',502,502.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '503-503.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('503-503.9',503,503.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '504-504.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('504-504.9',504,504.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '505-505.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('505-505.9',505,505.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '506-506.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('506-506.9',506,506.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '507-507.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('507-507.9',507,507.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '508-508.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('508-508.9',508,508.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '509-509.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('509-509.9',509,509.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '510-510.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('510-510.9',510,510.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '511-511.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('511-511.9',511,511.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '512-512.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('512-512.9',512,512.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '513-513.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('513-513.9',513,513.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '514-514.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('514-514.9',514,514.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '515-515.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('515-515.9',515,515.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '516-516.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('516-516.9',516,516.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '517-517.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('517-517.9',517,517.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '518-518.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('518-518.9',518,518.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '519-519.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('519-519.9',519,519.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '520-520.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('520-520.9',520,520.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '521-521.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('521-521.9',521,521.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '522-522.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('522-522.9',522,522.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '523-523.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('523-523.9',523,523.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '524-524.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('524-524.9',524,524.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '525-525.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('525-525.9',525,525.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '526-526.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('526-526.9',526,526.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '527-527.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('527-527.9',527,527.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '528-528.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('528-528.9',528,528.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '529-529.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('529-529.9',529,529.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '530-530.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('530-530.9',530,530.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '531-531.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('531-531.9',531,531.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '532-532.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('532-532.9',532,532.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '533-533.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('533-533.9',533,533.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '534-534.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('534-534.9',534,534.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '535-535.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('535-535.9',535,535.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '536-536.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('536-536.9',536,536.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '537-537.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('537-537.9',537,537.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '538-538.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('538-538.9',538,538.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '539-539.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('539-539.9',539,539.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '540-540.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('540-540.9',540,540.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '541-541.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('541-541.9',541,541.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '542-542.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('542-542.9',542,542.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '543-543.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('543-543.9',543,543.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '544-544.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('544-544.9',544,544.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '545-545.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('545-545.9',545,545.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '546-546.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('546-546.9',546,546.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '547-547.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('547-547.9',547,547.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '548-548.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('548-548.9',548,548.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '549-549.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('549-549.9',549,549.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '550-550.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('550-550.9',550,550.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '551-551.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('551-551.9',551,551.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '552-552.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('552-552.9',552,552.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '553-553.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('553-553.9',553,553.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '554-554.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('554-554.9',554,554.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '555-555.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('555-555.9',555,555.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '556-556.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('556-556.9',556,556.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '557-557.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('557-557.9',557,557.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '558-558.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('558-558.9',558,558.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '559-559.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('559-559.9',559,559.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '560-560.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('560-560.9',560,560.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '561-561.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('561-561.9',561,561.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '562-562.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('562-562.9',562,562.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '563-563.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('563-563.9',563,563.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '564-564.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('564-564.9',564,564.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '565-565.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('565-565.9',565,565.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '566-566.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('566-566.9',566,566.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '567-567.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('567-567.9',567,567.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '568-568.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('568-568.9',568,568.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '569-569.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('569-569.9',569,569.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '570-570.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('570-570.9',570,570.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '571-571.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('571-571.9',571,571.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '572-572.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('572-572.9',572,572.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '573-573.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('573-573.9',573,573.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '574-574.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('574-574.9',574,574.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '575-575.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('575-575.9',575,575.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '576-576.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('576-576.9',576,576.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '577-577.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('577-577.9',577,577.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '578-578.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('578-578.9',578,578.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '579-579.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('579-579.9',579,579.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '580-580.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('580-580.9',580,580.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '581-581.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('581-581.9',581,581.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '582-582.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('582-582.9',582,582.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '583-583.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('583-583.9',583,583.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '584-584.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('584-584.9',584,584.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '585-585.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('585-585.9',585,585.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '586-586.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('586-586.9',586,586.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '587-587.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('587-587.9',587,587.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '588-588.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('588-588.9',588,588.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '589-589.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('589-589.9',589,589.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '590-590.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('590-590.9',590,590.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '591-591.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('591-591.9',591,591.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '592-592.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('592-592.9',592,592.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '593-593.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('593-593.9',593,593.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '594-594.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('594-594.9',594,594.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '595-595.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('595-595.9',595,595.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '596-596.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('596-596.9',596,596.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '597-597.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('597-597.9',597,597.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '598-598.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('598-598.9',598,598.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '599-599.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('599-599.9',599,599.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '600-600.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('600-600.9',600,600.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '601-601.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('601-601.9',601,601.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '602-602.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('602-602.9',602,602.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '603-603.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('603-603.9',603,603.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '604-604.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('604-604.9',604,604.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '605-605.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('605-605.9',605,605.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '606-606.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('606-606.9',606,606.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '607-607.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('607-607.9',607,607.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '608-608.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('608-608.9',608,608.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '609-609.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('609-609.9',609,609.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '610-610.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('610-610.9',610,610.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '611-611.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('611-611.9',611,611.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '612-612.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('612-612.9',612,612.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '613-613.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('613-613.9',613,613.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '614-614.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('614-614.9',614,614.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '615-615.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('615-615.9',615,615.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '616-616.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('616-616.9',616,616.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '617-617.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('617-617.9',617,617.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '618-618.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('618-618.9',618,618.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '619-619.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('619-619.9',619,619.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '620-620.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('620-620.9',620,620.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '621-621.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('621-621.9',621,621.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '622-622.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('622-622.9',622,622.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '623-623.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('623-623.9',623,623.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '624-624.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('624-624.9',624,624.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '625-625.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('625-625.9',625,625.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '626-626.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('626-626.9',626,626.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '627-627.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('627-627.9',627,627.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '628-628.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('628-628.9',628,628.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '629-629.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('629-629.9',629,629.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '630-630.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('630-630.9',630,630.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '631-631.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('631-631.9',631,631.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '632-632.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('632-632.9',632,632.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '633-633.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('633-633.9',633,633.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '634-634.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('634-634.9',634,634.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '635-635.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('635-635.9',635,635.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '636-636.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('636-636.9',636,636.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '637-637.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('637-637.9',637,637.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '638-638.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('638-638.9',638,638.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '639-639.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('639-639.9',639,639.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '640-640.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('640-640.9',640,640.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '641-641.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('641-641.9',641,641.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '642-642.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('642-642.9',642,642.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '643-643.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('643-643.9',643,643.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '644-644.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('644-644.9',644,644.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '645-645.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('645-645.9',645,645.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '646-646.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('646-646.9',646,646.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '647-647.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('647-647.9',647,647.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '648-648.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('648-648.9',648,648.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '649-649.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('649-649.9',649,649.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '650-650.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('650-650.9',650,650.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '651-651.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('651-651.9',651,651.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '652-652.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('652-652.9',652,652.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '653-653.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('653-653.9',653,653.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '654-654.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('654-654.9',654,654.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '655-655.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('655-655.9',655,655.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '656-656.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('656-656.9',656,656.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '657-657.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('657-657.9',657,657.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '658-658.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('658-658.9',658,658.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '659-659.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('659-659.9',659,659.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '660-660.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('660-660.9',660,660.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '661-661.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('661-661.9',661,661.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '662-662.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('662-662.9',662,662.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '663-663.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('663-663.9',663,663.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '664-664.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('664-664.9',664,664.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '665-665.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('665-665.9',665,665.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '666-666.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('666-666.9',666,666.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '667-667.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('667-667.9',667,667.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '668-668.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('668-668.9',668,668.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '669-669.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('669-669.9',669,669.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '670-670.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('670-670.9',670,670.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '671-671.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('671-671.9',671,671.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '672-672.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('672-672.9',672,672.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '673-673.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('673-673.9',673,673.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '674-674.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('674-674.9',674,674.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '675-675.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('675-675.9',675,675.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '676-676.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('676-676.9',676,676.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '677-677.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('677-677.9',677,677.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '678-678.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('678-678.9',678,678.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '679-679.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('679-679.9',679,679.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '680-680.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('680-680.9',680,680.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '681-681.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('681-681.9',681,681.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '682-682.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('682-682.9',682,682.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '683-683.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('683-683.9',683,683.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '684-684.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('684-684.9',684,684.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '685-685.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('685-685.9',685,685.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '686-686.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('686-686.9',686,686.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '687-687.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('687-687.9',687,687.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '688-688.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('688-688.9',688,688.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '689-689.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('689-689.9',689,689.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '690-690.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('690-690.9',690,690.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '691-691.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('691-691.9',691,691.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '692-692.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('692-692.9',692,692.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '693-693.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('693-693.9',693,693.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '694-694.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('694-694.9',694,694.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '695-695.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('695-695.9',695,695.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '696-696.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('696-696.9',696,696.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '697-697.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('697-697.9',697,697.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '698-698.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('698-698.9',698,698.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '699-699.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('699-699.9',699,699.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '700-700.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('700-700.9',700,700.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '701-701.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('701-701.9',701,701.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '702-702.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('702-702.9',702,702.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '703-703.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('703-703.9',703,703.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '704-704.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('704-704.9',704,704.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '705-705.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('705-705.9',705,705.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '706-706.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('706-706.9',706,706.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '707-707.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('707-707.9',707,707.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '708-708.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('708-708.9',708,708.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '709-709.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('709-709.9',709,709.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '710-710.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('710-710.9',710,710.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '711-711.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('711-711.9',711,711.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '712-712.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('712-712.9',712,712.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '713-713.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('713-713.9',713,713.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '714-714.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('714-714.9',714,714.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '715-715.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('715-715.9',715,715.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '716-716.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('716-716.9',716,716.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '717-717.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('717-717.9',717,717.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '718-718.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('718-718.9',718,718.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '719-719.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('719-719.9',719,719.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '720-720.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('720-720.9',720,720.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '721-721.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('721-721.9',721,721.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '722-722.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('722-722.9',722,722.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '723-723.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('723-723.9',723,723.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '724-724.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('724-724.9',724,724.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '725-725.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('725-725.9',725,725.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '726-726.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('726-726.9',726,726.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '727-727.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('727-727.9',727,727.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '728-728.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('728-728.9',728,728.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '729-729.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('729-729.9',729,729.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '730-730.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('730-730.9',730,730.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '731-731.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('731-731.9',731,731.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '732-732.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('732-732.9',732,732.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '733-733.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('733-733.9',733,733.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '734-734.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('734-734.9',734,734.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '735-735.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('735-735.9',735,735.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '736-736.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('736-736.9',736,736.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '737-737.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('737-737.9',737,737.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '738-738.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('738-738.9',738,738.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '739-739.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('739-739.9',739,739.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '740-740.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('740-740.9',740,740.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '741-741.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('741-741.9',741,741.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '742-742.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('742-742.9',742,742.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '743-743.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('743-743.9',743,743.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '744-744.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('744-744.9',744,744.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '745-745.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('745-745.9',745,745.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '746-746.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('746-746.9',746,746.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '747-747.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('747-747.9',747,747.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '748-748.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('748-748.9',748,748.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '749-749.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('749-749.9',749,749.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '750-750.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('750-750.9',750,750.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '751-751.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('751-751.9',751,751.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '752-752.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('752-752.9',752,752.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '753-753.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('753-753.9',753,753.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '754-754.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('754-754.9',754,754.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '755-755.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('755-755.9',755,755.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '756-756.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('756-756.9',756,756.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '757-757.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('757-757.9',757,757.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '758-758.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('758-758.9',758,758.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '759-759.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('759-759.9',759,759.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '760-760.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('760-760.9',760,760.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '761-761.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('761-761.9',761,761.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '762-762.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('762-762.9',762,762.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '763-763.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('763-763.9',763,763.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '764-764.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('764-764.9',764,764.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '765-765.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('765-765.9',765,765.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '766-766.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('766-766.9',766,766.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '767-767.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('767-767.9',767,767.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '768-768.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('768-768.9',768,768.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '769-769.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('769-769.9',769,769.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '770-770.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('770-770.9',770,770.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '771-771.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('771-771.9',771,771.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '772-772.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('772-772.9',772,772.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '773-773.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('773-773.9',773,773.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '774-774.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('774-774.9',774,774.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '775-775.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('775-775.9',775,775.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '776-776.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('776-776.9',776,776.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '777-777.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('777-777.9',777,777.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '778-778.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('778-778.9',778,778.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '779-779.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('779-779.9',779,779.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '780-780.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('780-780.9',780,780.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '781-781.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('781-781.9',781,781.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '782-782.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('782-782.9',782,782.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '783-783.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('783-783.9',783,783.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '784-784.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('784-784.9',784,784.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '785-785.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('785-785.9',785,785.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '786-786.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('786-786.9',786,786.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '787-787.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('787-787.9',787,787.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '788-788.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('788-788.9',788,788.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '789-789.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('789-789.9',789,789.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '790-790.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('790-790.9',790,790.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '791-791.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('791-791.9',791,791.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '792-792.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('792-792.9',792,792.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '793-793.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('793-793.9',793,793.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '794-794.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('794-794.9',794,794.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '795-795.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('795-795.9',795,795.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '796-796.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('796-796.9',796,796.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '797-797.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('797-797.9',797,797.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '798-798.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('798-798.9',798,798.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '799-799.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('799-799.9',799,799.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '800-800.9' AND intReadingType = 1)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('800-800.9',800,800.9,1)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '0-0.14' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('0-0.14',0,0.14,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '0.15-0.24' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('0.15-0.24',0.15,0.24,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '0.25-0.34' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('0.25-0.34',0.25,0.34,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '0.35-0.44' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('0.35-0.44',0.35,0.44,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '0.45-0.54' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('0.45-0.54',0.45,0.54,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '0.55-0.64' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('0.55-0.64',0.55,0.64,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '0.65-0.74' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('0.65-0.74',0.65,0.74,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '0.75-0.84' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('0.75-0.84',0.75,0.84,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '0.85-0.94' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('0.85-0.94',0.85,0.94,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '0.95-1.04' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('0.95-1.04',0.95,1.04,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '1.05-1.14' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('1.05-1.14',1.05,1.14,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '1.15-1.24' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('1.15-1.24',1.15,1.24,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '1.25-1.34' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('1.25-1.34',1.25,1.34,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '1.35-1.44' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('1.35-1.44',1.35,1.44,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '1.45-1.54' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('1.45-1.54',1.45,1.54,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '1.55-1.64' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('1.55-1.64',1.55,1.64,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '1.65-1.74' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('1.65-1.74',1.65,1.74,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '1.75-1.84' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('1.75-1.84',1.75,1.84,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '1.85-1.94' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('1.85-1.94',1.85,1.94,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '1.95-2.04' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('1.95-2.04',1.95,2.04,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '2.05-2.14' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('2.05-2.14',2.05,2.14,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '2.15-2.24' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('2.15-2.24',2.15,2.24,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '2.25-2.34' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('2.25-2.34',2.25,2.34,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '2.35-2.44' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('2.35-2.44',2.35,2.44,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '2.45-2.54' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('2.45-2.54',2.45,2.54,2)
END
IF NOT EXISTS(SELECT  strReadingRange FROM tblGRReadingRanges WHERE strReadingRange = '2.55 & up' AND intReadingType = 2)
BEGIN
INSERT INTO tblGRReadingRanges VALUES('2.55 & up',2.55,999,2)
END
ELSE
BEGIN
	IF (SELECT intMaxValue FROM tblGRReadingRanges WHERE strReadingRange = '2.55 & up' AND intReadingType = 2) <> 999
	BEGIN
		UPDATE tblGRReadingRanges SET intMaxValue = 999 WHERE strReadingRange = '2.55 & up' AND intReadingType = 2
	END
END
PRINT 'End inserting fixed data in tblGRReadingRanges'

END