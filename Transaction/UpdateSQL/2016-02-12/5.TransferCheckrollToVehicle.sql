
/****** Object:  StoredProcedure [Checkroll].[TransferCheckrollToVehicleCharge]    Script Date: 23/2/2016 10:34:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Checkroll].[TransferCheckrollToVehicleCharge]
@EstateId nvarchar (50),
@ActiveMonthYearId nvarchar (50),    
@User nvarchar (50)  
AS

Declare @AMonth int
Declare @AYear numeric(18,0)
DECLARE @EstateCode nvarchar(50)
DECLARE @VHWSCode nvarchar(50)
DECLARE @VHDetailCostCode nvarchar(50)
DECLARE @DailyRate numeric(18,0)
DECLARE @CreatedDate datetime
DECLARE @Mandays numeric(18,2)
DECLARE @RefNo nvarchar(50)
SELECT @AMonth= AMonth,@AYear =AYear from General.ActiveMonthYear where ActiveMonthYearID = @ActiveMonthYearId
SET @CreatedDate = GETDATE()
--First delete vehicle that is part of checkroll for that month
Delete from Vehicle.VHChargeDetail where ModID = 1 And AMonth = @Amonth and AYear = @AYear

DECLARE cData CURSOR FOR   

select b.EstateCode,  d.VHWSCode,
 c.VHDetailCostCode,Checkroll.GetTeamActualDailyRate(a.GangMasterId,a.DistbDate) * Mandays, Mandays, DailyDistributionID from checkroll.DailyActivityDistribution  a 
inner join General.Estate b on a.EstateID = b.EstateID
inner join Vehicle.VHDetailCostCode c on a.VHDetailCostCodeID = c.VHDetailCostCodeID
inner join Vehicle.VHMaster d on a.VHID = d.VHID
where a.vhid is not null and a.ActiveMonthYearID = @ActiveMonthYearId
Open cData  
  
 FETCH NEXT FROM cData  
 INTO  @EstateCode, @VHWSCode,@VHDetailCostCode,@DailyRate,@Mandays,@RefNo

 WHILE @@FETCH_STATUS = 0   
 BEGIN  
	execute Vehicle.VHChargeDetailInsert @EstateCode,@VhwsCode,@EstateCode,@VhDetailCostCode,'V','Checkroll',@Ayear,
	@Amonth,@DailyRate,'Wages',@User,@CreatedDate,@User,@CreatedDate,'Checkroll','Checkroll','HK',@Mandays,@RefNo

   FETCH NEXT FROM cData  
     INTO @EstateCode, @VHWSCode,@VHDetailCostCode,@DailyRate,@Mandays,@RefNo
 END  
     
 CLOSE cData  
 DEALLOCATE cData  
