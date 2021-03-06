
SET ANSI_PADDING ON

go

CREATE NONCLUSTERED INDEX [_dta_index_DailyReceptionForRubber_7_1106271892__K2_K12_K11_K10_22_26_29] ON [Checkroll].[DailyReceptionForRubber]
(
	[DailyReceiptionID] ASC,
	[FieldNo] ASC,
	[YOP] ASC,
	[Afdeling] ASC
)
INCLUDE ( 	[PremiDasarLatex],
	[PremiDasarLump],
	[PremiTreelace]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

SET ANSI_PADDING ON

go

CREATE NONCLUSTERED INDEX [_dta_index_DailyReceptionForRubber_7_1106271892__K2_11_15_16_18_19] ON [Checkroll].[DailyReceptionForRubber]
(
	[DailyReceiptionID] ASC
)
INCLUDE ( 	[YOP],
	[CupLamp],
	[TreeLace],
	[COAglum],
	[DRCCupLump]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

SET ANSI_PADDING ON

go

CREATE NONCLUSTERED INDEX [_dta_index_DailyReceptionForRubber_7_1106271892__K11_K2_23_28] ON [Checkroll].[DailyReceptionForRubber]
(
	[YOP] ASC,
	[DailyReceiptionID] ASC
)
INCLUDE ( 	[PremiProgresifLatex],
	[PremiProgresifLump]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

SET ANSI_PADDING ON

go

CREATE NONCLUSTERED INDEX [_dta_index_DailyReceptionForRubber_7_1106271892__K11_K2_24_27] ON [Checkroll].[DailyReceptionForRubber]
(
	[YOP] ASC,
	[DailyReceiptionID] ASC
)
INCLUDE ( 	[PremiBonusLatex],
	[PremiBonusLump]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

SET ANSI_PADDING ON

go

CREATE NONCLUSTERED INDEX [_dta_index_DailyReceptionForRubber_7_1106271892__K2_K11_14_17] ON [Checkroll].[DailyReceptionForRubber]
(
	[DailyReceiptionID] ASC,
	[YOP] ASC
)
INCLUDE ( 	[Latex],
	[DRC]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

SET ANSI_PADDING ON

go

CREATE NONCLUSTERED INDEX [_dta_index_DailyReceptionForRubber_7_1106271892__K2_K12_K11_K10] ON [Checkroll].[DailyReceptionForRubber]
(
	[DailyReceiptionID] ASC,
	[FieldNo] ASC,
	[YOP] ASC,
	[Afdeling] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

SET ANSI_PADDING ON

go

CREATE NONCLUSTERED INDEX [_dta_index_DailyReceptionForRubber_7_1106271892__K11_K2_25] ON [Checkroll].[DailyReceptionForRubber]
(
	[YOP] ASC,
	[DailyReceiptionID] ASC
)
INCLUDE ( 	[PremiMinggu]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE STATISTICS [_dta_stat_1106271892_12_11_10] ON [Checkroll].[DailyReceptionForRubber]([FieldNo], [YOP], [Afdeling])
go

CREATE STATISTICS [_dta_stat_507617347_4_2_3] ON [Checkroll].[DailyAttendance]([ActiveMonthYearID], [DailyReceiptionID], [EstateID])
go

CREATE STATISTICS [_dta_stat_507617347_5_4_6_11] ON [Checkroll].[DailyAttendance]([RDate], [ActiveMonthYearID], [DailyTeamActivityID], [AttendanceSetupID])
go

CREATE STATISTICS [_dta_stat_507617347_4_6_11_2_5] ON [Checkroll].[DailyAttendance]([ActiveMonthYearID], [DailyTeamActivityID], [AttendanceSetupID], [DailyReceiptionID], [RDate])
go

CREATE STATISTICS [_dta_stat_507617347_3_4_2_6_5] ON [Checkroll].[DailyAttendance]([EstateID], [ActiveMonthYearID], [DailyReceiptionID], [DailyTeamActivityID], [RDate])
go

CREATE STATISTICS [_dta_stat_507617347_3_4_8_2_6_5] ON [Checkroll].[DailyAttendance]([EstateID], [ActiveMonthYearID], [EmpID], [DailyReceiptionID], [DailyTeamActivityID], [RDate])
go

CREATE STATISTICS [_dta_stat_507617347_2_6_5_11_8_4] ON [Checkroll].[DailyAttendance]([DailyReceiptionID], [DailyTeamActivityID], [RDate], [AttendanceSetupID], [EmpID], [ActiveMonthYearID])
go

CREATE STATISTICS [_dta_stat_263320348_7_2] ON [General].[ActiveMonthYear]([Status], [ActiveMonthYearID])
go

CREATE STATISTICS [_dta_stat_263320348_4_6_5] ON [General].[ActiveMonthYear]([ModID], [AMonth], [AYear])
go

