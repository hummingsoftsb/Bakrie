
/****** Object:  StoredProcedure [Production].[CalculateCurrentReading]    Script Date: 5/3/2015 8:44:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Select top 1 *  from Production.VolumeMaster
--exec [Production].CalculatecurrentReading 1.7,30,'M8','21R1',0
-- =============================================
-- Author:		Shankar D
-- Create date: 22-Oct-12
-- Description:	 To calculate Current reading for the cpo and pko production
-- =============================================
ALTER PROCEDURE [Production].[CalculateCurrentReading]
    @Height numeric(10,1),
    @Temprature numeric(5),
    @EstateID Nvarchar(50),
    @TankID Nvarchar(50),
    @CurrentReading numeric(18,3) out 

AS
	--BEGIN TRY
	BEGIN
		SET NOCOUNT ON;
		Declare @HeightWholeNumber numeric(10)
		Declare @HeightDecimal numeric(10)
		Declare @Difference numeric(18, 3)
		SET @HeightWholeNumber =convert(int,@Height - (@Height % 1))
		SET @HeightDecimal=convert(int, (@Height % 1) * 10)   
		SET @CurrentReading=0
		Set @Difference = 0
		SET @CurrentReading = (Select top 1 Volume  from Production.VolumeMaster with (nolock) Where Height=@HeightWholeNumber and EstateID=@EstateID  and TankID =@TankID)
		--select @CurrentReading
		BEGIN

				Declare @FractionValues Table([1mm]  numeric(18, 4), 
				[2mm] numeric(18, 4), 
				[3mm] numeric(18, 4), 
				[4mm] numeric(18, 4),
				[5mm] numeric(18, 4),
				[6mm] numeric(18, 4), 
				[7mm] numeric(18, 4),
				[8mm] numeric(18, 4), 
				[9mm] numeric(18, 4), 
				[10mm] numeric(18, 4))
				
				INSERT INTO @FractionValues 
				Select top 1 [1mm] , 
				[2mm], 
				[3mm], 
				[4mm], 
				[5mm], 
				[6mm], 
				[7mm], 
				[8mm], 
				[9mm], 
				[10mm] 
				from production.fractionmaster where tometer >=(@HeightWholeNumber) and frommeter<=(@HeightWholeNumber) and EstateID=@EstateID and Production.FractionMaster.TankID = @TankID
				--select * from @FractionValues
				--print @HeightWholeNumber
				--print @HeightDecimal
		END
		
		BEGIN
			
			Set @Difference = (Select top 1  Case @HeightDecimal
				When 0 Then 0
				When 1 Then  [1mm] * 0.1
				When 2 Then [2mm] * 0.2
				When 3 Then [3mm] * 0.3
				When 4 Then [4mm] * 0.4
				When 5 Then [5mm] * 0.5
				When 6 Then [6mm] * 0.6
				When 7 Then [7mm] * 0.7
				When 8 Then [8mm] * 0.8
				When 9 Then [9mm] * 0.9
				else [10mm] * 1.0
				End
				from @FractionValues)
			SET @CurrentReading= @CurrentReading +	@Difference
			SET @currentReading=@CurrentReading * (Select top 1 CorrectionFactor from Production.TemperatureMaster with (nolock) where Temperature=@Temprature and Production.TemperatureMaster.TankID = @TankID  and EstateID=@EstateID)			
			SET @currentReading=@CurrentReading * (Select top 1 SpecificGravity from Production.TemperatureMaster with (nolock) where Temperature=@Temprature and Production.TemperatureMaster.TankID = @TankID  and EstateID=@EstateID)			
		select @currentReading
		END 
		--print @currentReading
   END
