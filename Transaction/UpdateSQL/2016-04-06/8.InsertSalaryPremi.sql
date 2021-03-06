
/****** Object:  StoredProcedure [Checkroll].[InsertSalaryPremi]    Script Date: 12/4/2016 7:35:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--========
-- Author : Dadang Adi Hendradi
-- update : Sabtu, 20 Mar 2010, 14:24
--
--=======

ALTER PROCEDURE [Checkroll].[InsertSalaryPremi]
	@EstateID nvarchar (50),
	@ActiveMonthYearID nvarchar (50),
	@User nvarchar (50)

AS

Declare @count int
Declare	@pTotRow Numeric(18,0)
Declare @RDate datetime
Declare @FaktorPembagi int
Declare @EmpID as Nvarchar (50)
Declare @Premi AS Numeric(18,2)
Declare @KraniPremi AS Numeric(18,2)
Declare @KraniID as nvarchar(50)

BEGIN	
	
	DECLARE @Amonth int
	DECLARE @Ayear int

	Select @Amonth= Amonth, @Ayear =Ayear from General.ActiveMonthYear where ActiveMonthYearID = @ActiveMonthYearID

	--First Update Daily Team activity with Premi Mandor 		
	SET XACT_ABORT ON
	DECLARE CR_DA CURSOR FOR 

	SELECT 
	RDate, MandoreID,
	SUM(MandorPremi) as MandorPremi, FaktorPembagi
	FROM 
	(
	SELECT 
	a.ActiveMonthYearID, a.EstateID, EstateName, c.AMonth, c.AYear, d.GangName, RDate, e.EmpName as MandorName, 
	(((TValue1+TValue2+TValue3+TotalBoronganValue+TLooseFruitsValue)/z.FaktorPembagi)*1.5) as MandorPremi,
	(TValue1+TValue2+TValue3+TotalBoronganValue+TLooseFruitsValue) as SUMPREMI, z.FaktorPembagi,a.MandoreID 
	FROM [Checkroll].[ReceptionTargetDetail] a
	INNER JOIN [General].[Estate] b on a.EstateID = b.EstateID
	INNER JOIN [General].[ActiveMonthYear] c on a.ActiveMonthYearID = c.ActiveMonthYearID
	INNER JOIN [Checkroll].[GangMaster] d on a.GangMasterID = d.GangMasterID
	INNER JOIN [Checkroll].[CREmployee] e on a.MandoreID = e.EmpID
	INNER JOIN [Checkroll].[CREmployee] f on a.KraniID = f.EmpID
	inner Join (Select Count(*) as FaktorPembagi, GangMasterID,DDAte from Checkroll.DailyAttendance inner join Checkroll.AttendanceSetup on 
	Checkroll.DailyAttendance.AttendanceSetupID = Checkroll.AttendanceSetup.AttendanceSetupID
	inner join Checkroll.DailyTeamActivity on Checkroll.DailyAttendance.DailyTeamActivityID = Checkroll.DailyTeamActivity.DailyTeamActivityID
	Where AttendanceCode = '11' and ActiveMonthYearID = @ActiveMonthYearID Group By Gangmasterid,DDate) Z on a.GangMasterID = z.gangmasterid and a.RDate = z.DDAte
	WHERE a.ActiveMonthYearID = @ActiveMonthYearID AND a.EstateID = @EstateID
	) as tbl
	GROUP BY RDate, FaktorPembagi,MandoreId
	
	Open CR_DA;

	FETCH NEXT FROM CR_DA
	INTO @RDate, 
		@EmpID,
		@Premi,@FaktorPembagi
		
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		
		Update Checkroll.DailyTeamActivity Set MandorPremi = @Premi
		WHERE  
				Convert(date,DDate,103) = Convert(date,@RDate,103)
					AND MandoreID = @EmpID  
			
	
					
		FETCH NEXT FROM CR_DA
 		INTO 
 			@RDate, 
		@EmpID,
		@Premi,@FaktorPembagi		
	END;
	
	CLOSE CR_DA;

	DEALLOCATE CR_DA
	--Premi Deres
	DECLARE CR_DA CURSOR FOR 

	SELECT 
	DDate, MandoreId,KraniID,
	SUM(PremiMandor) as MandorPremi, SUM(PremiKerani) as KraniPremi, FaktorPembagi
	FROM 
	(
	Select b.ActiveMonthYearID,b.EstateID,f.GangName, e.DDate, g.EmpName as MandorName,FaktorPembagi, SUm(PremiDasar + PremiBonus + PremiTreeLace + PremiProgresif + PremiBonus + PremiMinggu) / FaktorPembagi * 1.5 as PremiMandor, e.Mandoreid,e.KraniID,
	h.EmpName as KeraniName,SUm(PremiDasar + PremiBonus + PremiTreeLace + PremiProgresif + PremiBonus + PremiMinggu) / FaktorPembagi * 1.25 as PremiKerani,SUm(PremiDasar + PremiBonus + PremiTreeLace + PremiProgresif + PremiBonus + PremiMinggu) as TotalPremi
	from (Select Sum(a.PremiDasarLatex + a.PremiDasarLump) as PremiDasar, Sum(a.PremiProgresifLatex + a.PremiProgresifLump) as PremiProgresif,
	Sum(a.PremiBonusLatex + a.PremiBonusLump) as PremiBonus, Sum(a.PremiTreelace) as PremiTreeLace, Sum(a.PremiMinggu) as PremiMinggu,DailyReceiptionID  from Checkroll.DailyReceptionForRubber a
	WHere Month(a.DateRubber) = @Amonth and Year(a.dateRubber) = @Ayear
	Group BY DailyReceiptionID) a
	inner Join Checkroll.DailyAttendance b On a.DailyReceiptionID = b.DailyReceiptionID
	INNER JOIN Checkroll.DailyTeamActivity e on b.DailyTeamActivityID = e.DailyTeamActivityID
	INNER JOIN [Checkroll].[GangMaster] f on e.GangMasterID = f.GangMasterID
	INNER JOIN [Checkroll].[CREmployee] g on e.MandoreID = g.EmpID
	INNER JOIN [Checkroll].[CREmployee] h on e.KraniID = h.EmpID
	inner Join (Select Count(*) as FaktorPembagi, GangMasterID,DDAte from Checkroll.DailyAttendance inner join Checkroll.AttendanceSetup on 
	Checkroll.DailyAttendance.AttendanceSetupID = Checkroll.AttendanceSetup.AttendanceSetupID
	inner join Checkroll.DailyTeamActivity on Checkroll.DailyAttendance.DailyTeamActivityID = Checkroll.DailyTeamActivity.DailyTeamActivityID
	Where AttendanceCode = '11' And Checkroll.DailyTeamActivity.Activity = 'Deres' and ActiveMonthYearID = @ActiveMonthYearID Group By Gangmasterid,DDate) Z on e.GangMasterID = z.gangmasterid and e.DDate = z.DDAte
	WHERE b.ActiveMonthYearID = @ActiveMonthYearID AND b.EstateID = @EstateID
	Group by b.ActiveMonthYearID,b.EstateID,f.GangName, e.DDate, g.EmpName,FaktorPembagi,h.EmpName,e.Mandoreid,e.KraniID
	) as tbl
	GROUP BY  DDate, MandoreId,KraniID,FaktorPembagi

	Open CR_DA;

	FETCH NEXT FROM CR_DA
	INTO @RDate, 
		@EmpID, @KraniID,
		@Premi, @KraniPremi,@FaktorPembagi
		
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		
		Update Checkroll.DailyTeamActivity Set MandorPremi = @Premi
		WHERE  
				Convert(date,DDate,103) = Convert(date,@RDate,103)
					AND MandoreID = @EmpID  
			
		Update Checkroll.DailyTeamActivity Set KraniPremi = @KraniPremi
		WHERE  
				Convert(date,DDate,103) = Convert(date,@RDate,103)
					AND KraniID = @KraniID  
			
	
					
		FETCH NEXT FROM CR_DA
 		INTO @RDate, 
		@EmpID, @KraniID,
		@Premi, @KraniPremi,@FaktorPembagi		
	END;
	
	CLOSE CR_DA;

	DEALLOCATE CR_DA



	-- Update krani Panen
	UPDATE b set b.KraniPremi = Isnull(a.KraniPremiKg/1000,0) * 1250   from Checkroll.DailyAttendanceMandor a
	inner join Checkroll.DailyTeamActivity b on Convert(date,a.RDate,103) = Convert(date,b.DDate,103) and a.EmpID = b.KraniID
	where Activity = 'Panen' and a.ActiveMonthYearID = @ActiveMonthYearID


	--Update Premi Rajin
	update a set PremiRajin = 1500 from Checkroll.ReceptionTargetDetail a
	inner join Checkroll.CREmployee b on a.EmpID = b.EmpID
	where a.TValue1 > 0 or a.TValue2 > 0 or a.TValue3 > 0
	and (b.Category <> 'HIP' or b.Category <> 'HIPS') and (a.ActiveMonthYearID = @ActiveMonthYearID)


	
END








