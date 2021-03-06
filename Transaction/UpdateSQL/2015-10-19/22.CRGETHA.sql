
/****** Object:  UserDefinedFunction [Checkroll].[CRGetHA]    Script Date: 28/10/2015 9:03:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--===
--Gets which division and total Hectarage of that matured area based on first record in daily reception 
-- of the mandor besar's harvesting team
--===
ALTER FUNCTION [Checkroll].[CRGetHA] (
	@MandorebesarId nvarchar(50)
	,@Activity nvarchar(50)
	,@DDate smalldatetime)
RETURNS int
AS
BEGIN
	Declare @DailyReceptionId nvarchar(50)
	DECLARE @HaDiawasi numeric(18,4)
	Declare @DivId nvarchar(50)
	Declare @DailyTeamActivityID nvarchar(50)
	-- First Get  DailyTeamActivityID and then get the ReceptionId
	Select @DailyTeamActivityID = DailyTeamActivityID from Checkroll.DailyTeamActivity where MandorBesarID = @MandorebesarId and DDate = @DDate AND Activity = @Activity

	select top 1 @DailyReceptionId = DailyReceiptionID from Checkroll.DailyAttendance where DailyTeamActivityID = @DailyTeamActivityID and attendancesetupid = '02R94'

	if @Activity = 'Panen'
	begin
		select top 1 @DivId = DivID from Checkroll.DailyReceiption where DailyReceiptionID = @DailyReceptionId
		Select @HaDiawasi=Sum(PlantedHect) from General.blockmaster where DivID = @DivId and BlockStatus = 'Matured' and Cropid = 'M1'
	end
	else
	begin
		select top 1 @DivId = Afdeling from Checkroll.DailyReceptionForRubber where DailyReceiptionID = @DailyReceptionId
		Select @HaDiawasi=Sum(PlantedHect) from General.blockmaster where DivID = @DivId and BlockStatus = 'Matured' and Cropid = 'M2'
	end		

	RETURN (@HaDiawasi);	
END;



