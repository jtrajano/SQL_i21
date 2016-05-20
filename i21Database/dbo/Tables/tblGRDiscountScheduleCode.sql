﻿CREATE TABLE [dbo].[tblGRDiscountScheduleCode]
(
	[intDiscountScheduleCodeId] INT NOT NULL  IDENTITY, 
    [intDiscountScheduleId] INT NOT NULL, 
    [intDiscountCalculationOptionId] INT NOT NULL DEFAULT 1, 
    [intShrinkCalculationOptionId] INT NOT NULL DEFAULT 1, 
    [ysnZeroIsValid] BIT NOT NULL DEFAULT 1, 
    [dblMinimumValue] NUMERIC(24, 10) NOT NULL DEFAULT 0, 
    [dblMaximumValue] NUMERIC(24, 10) NOT NULL , 
    [dblDefaultValue] NUMERIC(24, 10) NOT NULL DEFAULT 0, 
	[ysnQualityDiscount] BIT NOT NULL DEFAULT 0,
	[ysnDryingDiscount] BIT NOT NULL DEFAULT 0,
	[dtmEffectiveDate] DATETIME NULL,
	[dtmTerminationDate] DATETIME NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
	[intSort] INT NULL , 
    [strDiscountChargeType] NVARCHAR(30)  COLLATE Latin1_General_CI_AS NULL,
	[intItemId] INT NULL,  
    CONSTRAINT [PK_tblGRDiscountScheduleCode_intDiscountScheduleCodeId] PRIMARY KEY ([intDiscountScheduleCodeId]), 	
    CONSTRAINT [FK_tblGRDiscountScheduleCode_tblGRDiscountSchedule_intDiscountScheduleId] FOREIGN KEY ([intDiscountScheduleId]) REFERENCES [tblGRDiscountSchedule]([intDiscountScheduleId]), 
    CONSTRAINT [FK_tblGRDiscountScheduleCode_tblGRDiscountCalculationOption_intValueFieldId_intDiscountCalculationOptionId] FOREIGN KEY ([intDiscountCalculationOptionId]) REFERENCES [tblGRDiscountCalculationOption]([intValueFieldId]),
	CONSTRAINT [FK_tblGRDiscountScheduleCode_tblGRShrinkCalculationOption_intValueFieldId_intShrinkCalculationOptionId] FOREIGN KEY ([intShrinkCalculationOptionId]) REFERENCES [tblGRShrinkCalculationOption]([intValueFieldId]),
	CONSTRAINT [FK_tblGRDiscountScheduleCode_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
)