﻿CREATE TYPE StagingCommanderFuelTotal AS TABLE
(
	[intRowCount] [int] NULL,
	[intFuelingPositionId] INT NOT NULL,
    [intProductNumber] NVARCHAR(10) NOT NULL,
    [dblFuelVolume] DECIMAL(18, 6) NOT NULL,
    [dblFuelMoney] DECIMAL(18, 6) NOT NULL
)