
/****** Object:  StoredProcedure [Checkroll].[UpLoadSalary]    Script Date: 25/8/2015 4:06:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
--=====  
-- Modified by : Dadang Adi Hendradi  
-- Modified On : Sabtu, 13 Mar 2010, 11:39  
--               - Tambahan perbaikan Query  
--               - penambahan S2, S3, S4 karena belum masuk  
--               - Tambahan Adjustment hari utk hari lain utk perbaikan di Hari Lain  
--  
--               - Sabtu, 13 Mar 2010, 23:39  
--                 I1 dan I2 masuk ke Hadir  
--====  
  
--EXEC [Checkroll].[UpLoadSalary] '01R81', 'M1', '01', 'Anand', '09/25/2010'  
ALTER procedure [Checkroll].[UpLoadSalary]  
 @ActiveMonthYearID nvarchar (50),  
 @EstateID nvarchar (50),  
 @EstateCode nvarchar(50),  
 @User nvarchar (50),  
 @SalaryProcDate Date  
  
AS  
  
Declare @count int  
Declare @pTotRow Numeric(18,0)  
Declare @SalaryID AS Nvarchar (50)  
Declare @GangMasterID as Nvarchar (50)  
Declare @EmpID as Nvarchar (50)  
DECLARE @EmpName nvarchar(50)  
Declare @Category AS Nvarchar (50)  
Declare @BasicRate AS Numeric(18,2)  
Declare @MaritalStatus AS Nvarchar (50)  
Declare @NPWP AS nvarchar (50)  
Declare @TIDAKHADIR AS Numeric(18,2)  
Declare @HADIR AS Numeric(18,2)  
Declare @Upah AS Numeric(18,2)  
Declare @LAIN  AS Numeric(18,2)  
Declare @HariLainUpah AS Numeric(18,2)  
Declare @TotalBasic AS Numeric(18,2)  
  
DECLARE @WorkingDays int  
DECLARE @NoOfSundays int  
DECLARE @AdjustmentDay int  
  
  
   
 DELETE Checkroll.Salary  
 WHERE   
  EstateID = @EstateID   
  AND ActiveMonthYearID = @ActiveMonthYearID  
   
 DECLARE CR_DA CURSOR FOR   
  
 SELECT DISTINCT   
   C_ATTSUMMARY.EmpID  
   ,C_EMP.EmpName  
   ,C_ATTSUMMARY.EstateID  
   , C_ATTSUMMARY.ActiveMonthYearID  
   ,C_GANGEMPSETUP.GangMasterID  
   , C_EMP.Category  
   , C_RS.BasicRate  
   , C_EMP.MaritalStatus  
   , C_EMP.NPWP  
   , SUM(ISNULL(C_ATTSUMMARY.AB,0))   
   + SUM(ISNULL(C_ATTSUMMARY.I0,0))   
   + SUM(ISNULL(C_ATTSUMMARY.S0,0))   
   + SUM(ISNULL(C_ATTSUMMARY.SG,0)) AS TidakHadir  
   
   
   , SUM(ISNULL(C_ATTSUMMARY.[11M],0))   
   + SUM(ISNULL(C_ATTSUMMARY.[51M],0))
   + SUM(ISNULL(C_ATTSUMMARY.J1M,0)) + Sum(ISNULL(C_ATTSUMMARY.[52M],0)) + Sum(ISNULL(C_ATTSUMMARY.[53M],0))
   + Sum(ISNULL(C_ATTSUMMARY.[54M],0)) + Sum(ISNULL(C_ATTSUMMARY.[55M],0)) + Sum(ISNULL(C_ATTSUMMARY.[56M],0)) 
   AS Hadir  
   ,   
   (SUM(ISNULL(C_ATTSUMMARY.[11M],0))   
   + (SUM(  ISNULL(C_ATTSUMMARY.[51M],0) * ISNULL(C_ATTSUMMARY.[51M],0)  ))  
   + SUM(ISNULL(C_ATTSUMMARY.J1M,0)) ) * C_RS.BasicRate AS Upah  
   ,   
   CASE WHEN C_EMP.Category ='KHT'  
     THEN  
    (SUM(ISNULL(C_ATTSUMMARY.H1M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.L0M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.L1M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.S1M,0))  
    + SUM(ISNULL(C_ATTSUMMARY.S2M,0))  
    + SUM(ISNULL(C_ATTSUMMARY.S3M,0))  
    + SUM(ISNULL(C_ATTSUMMARY.S4M,0))  
    + SUM(ISNULL(C_ATTSUMMARY.M0M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.M1M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.CBM,0))  
    + SUM(ISNULL(C_ATTSUMMARY.CDM,0))   
    + SUM(ISNULL(C_ATTSUMMARY.CHM,0))   
    + SUM(ISNULL(C_ATTSUMMARY.CTM,0))   
    + SUM(ISNULL(C_ATTSUMMARY.I1M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.I2M,0))
	+ SUM(ISNULL(C_ATTSUMMARY.TPM,0))   
    + SUM(ISNULL(C_ATTSUMMARY.TP1M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.TP2M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.TP3M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.JLM,0))) 
	+ ISNUll(Checkroll.CRFnGetNoOfSundays(@EstateID, G_AMY.AMonth, G_AMY.AYear) ,0)
	+ ISNULL(Checkroll.CRFnGetNoOfPublicHolidays(@EstateID, G_AMY.AMonth, G_AMY.AYear) ,0)
              END   
    AS Lain  
              ,   
   CASE WHEN C_EMP.Category ='KHT'  
    THEN   
            (SUM(ISNULL(C_ATTSUMMARY.H1M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.L0M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.L1M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.S1M,0))  
    + SUM(ISNULL(C_ATTSUMMARY.S2M,0))  
    + SUM(ISNULL(C_ATTSUMMARY.S3M,0))  
    + SUM(ISNULL(C_ATTSUMMARY.S4M,0))  
    + SUM(ISNULL(C_ATTSUMMARY.M0M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.M1M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.CBM,0))  
    + SUM(ISNULL(C_ATTSUMMARY.CDM,0))   
    + SUM(ISNULL(C_ATTSUMMARY.CHM,0))   
    + SUM(ISNULL(C_ATTSUMMARY.CTM,0))   
    + SUM(ISNULL(C_ATTSUMMARY.I1M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.I2M,0)) 
	+ SUM(ISNULL(C_ATTSUMMARY.TPM,0))   
    + SUM(ISNULL(C_ATTSUMMARY.TP1M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.TP2M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.TP3M,0))     
    + SUM(ISNULL(C_ATTSUMMARY.JLM,0))) -- Added by Palani  
	+ ISNUll(Checkroll.CRFnGetNoOfSundays(@EstateID, G_AMY.AMonth, G_AMY.AYear) ,0)
	+ ISNULL(Checkroll.CRFnGetNoOfPublicHolidays(@EstateID, G_AMY.AMonth, G_AMY.AYear) ,0)
END   
   * C_RS.BasicRate AS HariLainUpah  
     ,   
              WorkingDays = Checkroll.CRFnGetWorkingDays(@EstateID, G_AMY.AMonth, G_AMY.AYear)  
              ,NoOfSundays = Checkroll.CRFnGetNoOfSundays(@EstateID, G_AMY.AMonth, G_AMY.AYear)  
              ,AdjustmentDay = Checkroll.CRFnGetAdjustmentDay(@EstateID, G_AMY.AMonth, G_AMY.AYear)  
 FROM           
  Checkroll.AttendanceSummary AS C_ATTSUMMARY  
  INNER JOIN Checkroll.CREmployee AS C_EMP ON C_ATTSUMMARY.EmpID = C_EMP.EmpID  
  INNER JOIN Checkroll.RateSetup AS C_RS ON C_EMP.Category = C_RS.Category  
  LEFT JOIN Checkroll.GangEmployeeSetup AS C_GANGEMPSETUP ON C_ATTSUMMARY.EmpID = C_GANGEMPSETUP.EmpID  
  INNER JOIN General.ActiveMonthYear AS G_AMY ON C_ATTSUMMARY.ActiveMonthYearID = G_AMY.ActiveMonthYearID  
  
 WHERE  
  C_ATTSUMMARY.EstateID = @EstateID  
  AND C_ATTSUMMARY.ActiveMonthYearID = @ActiveMonthYearID  
  And C_EMP.Category IN('KHT','KHL')
 GROUP BY  
  C_ATTSUMMARY.EmpID  
  ,C_EMP.EmpName  
  ,C_ATTSUMMARY.EstateID  
  ,C_ATTSUMMARY.ActiveMonthYearID  
  ,C_GANGEMPSETUP.GangMasterID  
  ,C_EMP.Category  
  ,C_RS.BasicRate  
  ,C_EMP.MaritalStatus  
  ,C_EMP.NPWP  
  ,G_AMY.AMonth  
  ,G_AMY.AYear  
  
 Open CR_DA  
  
 FETCH NEXT FROM CR_DA  
 INTO   
 @EmpID  
 ,@EmpName  
 ,@EstateID, @ActiveMonthYearID, @GangMasterID,   
 @Category,@BasicRate,@MaritalStatus, @NPWP, @TIDAKHADIR,  
 @HADIR, @Upah, @LAIN, @HariLainUpah--, @TotalBasic  
 ,@WorkingDays  
 ,@NoOfSundays  
 ,@AdjustmentDay  
    
 WHILE @@FETCH_STATUS = 0   
 BEGIN  
    
       
   SELECT @count = (ISNULL(MAX(Id),0) + 1) FROM Checkroll.Salary  ;  
   SET @SalaryID  = @EstateCode+'R'+ CONVERT(NVARCHAR,@count);  
    
    
   INSERT INTO Checkroll.Salary (  
   SalaryProcDate,   
   SalaryID,  
   EmpID,  
   EstateId,  
   ActiveMonthYearId,  
   GangMasterId,   
    Category,  
    MStatus,  
    NPWP,  
    Absent,  
    Hari,  
    Upah,   
    HariLain,  
    HarinLainUpah,  
    TotalBasic,  
    CreatedBy,CreatedOn,ModifiedBy,ModifiedOn      
   )  
   values (  
   @SalaryProcDate,  
   @SalaryID,  
   @EmpID,  
   @EstateId,  
   @ActiveMonthYearId,  
   @GangMasterId,   
    @Category,  
    @MaritalStatus,  
    @NPWP,  
    @TIDAKHADIR,  
    @HADIR,  
    @Upah,   
    @LAIN,  
    @HariLainUpah,  
    CASE WHEN @Category ='KHT'  
     THEN ISNULL(@Upah,0)+ISNULL(@HariLainUpah,0)    
     ELSE @Upah END,  
    @User,GetDate(),@User,GetDate()   
   )  
       
     
   FETCH NEXT FROM CR_DA  
    INTO   
    @EmpID  
    ,@EmpName  
    ,@EstateID, @ActiveMonthYearID, @GangMasterID,   
    @Category,@BasicRate,@MaritalStatus, @NPWP, @TIDAKHADIR,  
    @HADIR, @Upah, @LAIN, @HariLainUpah--, @TotalBasic  
   ,@WorkingDays  
   ,@NoOfSundays  
   ,@AdjustmentDay  
         
 END  
 CLOSE CR_DA  
  
 DEALLOCATE CR_DA  
 
 
 --Repeat Again for HIP workers
   
 DECLARE CR_DA CURSOR FOR   
 
 SELECT DISTINCT   
   C_ATTSUMMARY.EmpID  
   ,C_EMP.EmpName  
   ,C_ATTSUMMARY.EstateID  
   , C_ATTSUMMARY.ActiveMonthYearID  
   ,C_GANGEMPSETUP.GangMasterID  
   , C_EMP.Category  
   , C_RS.StdRate as BasicRate  
   , C_EMP.MaritalStatus  
   , C_EMP.NPWP  
   , SUM(ISNULL(C_ATTSUMMARY.AB,0))   
   + SUM(ISNULL(C_ATTSUMMARY.I0,0))   
   + SUM(ISNULL(C_ATTSUMMARY.S0,0))   
   + SUM(ISNULL(C_ATTSUMMARY.SG,0)) AS TidakHadir  
   
   
   , SUM(ISNULL(C_ATTSUMMARY.[11],0))   
   + SUM(ISNULL(C_ATTSUMMARY.[51M],0))
   + SUM(ISNULL(C_ATTSUMMARY.J1M,0)) + Sum(ISNULL(C_ATTSUMMARY.[52M],0)) + Sum(ISNULL(C_ATTSUMMARY.[53M],0))
   + Sum(ISNULL(C_ATTSUMMARY.[54M],0)) + Sum(ISNULL(C_ATTSUMMARY.[55M],0)) + Sum(ISNULL(C_ATTSUMMARY.[56M],0)) 
   AS Hadir  
   ,   
   (SUM(ISNULL(C_ATTSUMMARY.[11M],0))   
   + Sum(ISNULL(C_ATTSUMMARY.[51M],0)) + Sum(ISNULL(C_ATTSUMMARY.[52M],0)) + Sum(ISNULL(C_ATTSUMMARY.[53M],0))
   + Sum(ISNULL(C_ATTSUMMARY.[54M],0)) + Sum(ISNULL(C_ATTSUMMARY.[55M],0)) + Sum(ISNULL(C_ATTSUMMARY.[56M],0)) 
   + SUM(ISNULL(C_ATTSUMMARY.J1M,0)) ) * C_RS.StdRate / C_RS.RiceDividerDays AS Upah  
   ,   
   CASE WHEN C_EMP.Category ='HIP' or C_Emp.Category = 'HIPS'  
     THEN  
    (SUM(ISNULL(C_ATTSUMMARY.H1M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.L0M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.L1M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.S1M,0))  
    + SUM(ISNULL(C_ATTSUMMARY.S2M,0))  
    + SUM(ISNULL(C_ATTSUMMARY.S3M,0))  
    + SUM(ISNULL(C_ATTSUMMARY.S4M,0))  
    + SUM(ISNULL(C_ATTSUMMARY.M0M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.M1M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.CBM,0))  
    + SUM(ISNULL(C_ATTSUMMARY.CDM,0))   
    + SUM(ISNULL(C_ATTSUMMARY.CHM,0))   
    + SUM(ISNULL(C_ATTSUMMARY.CTM,0))   
    + SUM(ISNULL(C_ATTSUMMARY.I1M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.I2M,0))
	+ SUM(ISNULL(C_ATTSUMMARY.TPM,0))   
    + SUM(ISNULL(C_ATTSUMMARY.TP1M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.TP2M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.TP3M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.JLM,0)))
	+ ISNUll(Checkroll.CRFnGetNoOfSundays(@EstateID, G_AMY.AMonth, G_AMY.AYear) ,0)
	+ ISNULL(Checkroll.CRFnGetNoOfPublicHolidays(@EstateID, G_AMY.AMonth, G_AMY.AYear) ,0)
              END   
    AS Lain  
              ,   
   CASE WHEN C_EMP.Category ='HIP' or C_Emp.Category = 'HIPS'
    THEN   
             (SUM(ISNULL(C_ATTSUMMARY.H1M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.L0M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.L1M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.S1M,0))  
    + SUM(ISNULL(C_ATTSUMMARY.S2M,0))  
    + SUM(ISNULL(C_ATTSUMMARY.S3M,0))  
    + SUM(ISNULL(C_ATTSUMMARY.S4M,0))  
    + SUM(ISNULL(C_ATTSUMMARY.M0M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.M1M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.CBM,0))  
    + SUM(ISNULL(C_ATTSUMMARY.CDM,0))   
    + SUM(ISNULL(C_ATTSUMMARY.CHM,0))   
    + SUM(ISNULL(C_ATTSUMMARY.CTM,0))   
    + SUM(ISNULL(C_ATTSUMMARY.I1M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.I2M,0)) 
	+ SUM(ISNULL(C_ATTSUMMARY.TPM,0))   
    + SUM(ISNULL(C_ATTSUMMARY.TP1M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.TP2M,0))   
    + SUM(ISNULL(C_ATTSUMMARY.TP3M,0))     
    + SUM(ISNULL(C_ATTSUMMARY.JLM,0))) -- Added by Palani 
	+ ISNUll(Checkroll.CRFnGetNoOfSundays(@EstateID, G_AMY.AMonth, G_AMY.AYear) ,0)
	+ ISNULL(Checkroll.CRFnGetNoOfPublicHolidays(@EstateID, G_AMY.AMonth, G_AMY.AYear) ,0)
	        END   
   * C_RS.StdRate / C_RS.RiceDividerDays AS HariLainUpah  
     ,   
              WorkingDays = Checkroll.CRFnGetWorkingDays(@EstateID, G_AMY.AMonth, G_AMY.AYear)  
              ,NoOfSundays = Checkroll.CRFnGetNoOfSundays(@EstateID, G_AMY.AMonth, G_AMY.AYear)  
              ,AdjustmentDay = Checkroll.CRFnGetAdjustmentDay(@EstateID, G_AMY.AMonth, G_AMY.AYear)  
 FROM           
  Checkroll.AttendanceSummary AS C_ATTSUMMARY  
  INNER JOIN Checkroll.CREmployee AS C_EMP ON C_ATTSUMMARY.EmpID = C_EMP.EmpID  
  INNER JOIN Checkroll.RateSetup AS C_RS ON C_EMP.Grade = C_RS.Grade and C_EMP.Level = C_RS.HIPLevel   and C_RS.Category = 'KT'
  LEFT JOIN Checkroll.GangEmployeeSetup AS C_GANGEMPSETUP ON C_ATTSUMMARY.EmpID = C_GANGEMPSETUP.EmpID  
  INNER JOIN General.ActiveMonthYear AS G_AMY ON C_ATTSUMMARY.ActiveMonthYearID = G_AMY.ActiveMonthYearID  
 WHERE  
  C_ATTSUMMARY.EstateID = @EstateID  
  AND C_ATTSUMMARY.ActiveMonthYearID = @ActiveMonthYearID  
  And C_EMP.Category IN('HIP','HIPS')
 GROUP BY  
  C_ATTSUMMARY.EmpID  
  ,C_EMP.EmpName  
  ,C_ATTSUMMARY.EstateID  
  ,C_ATTSUMMARY.ActiveMonthYearID  
  ,C_GANGEMPSETUP.GangMasterID  
  ,C_EMP.Category  
  ,C_RS.StdRate 
  ,C_EMP.MaritalStatus  
  ,C_EMP.NPWP  
  ,G_AMY.AMonth  
  ,G_AMY.AYear ,C_RS.RiceDividerDays
 
 Open CR_DA  
  
 FETCH NEXT FROM CR_DA  
 INTO   
 @EmpID  
 ,@EmpName  
 ,@EstateID, @ActiveMonthYearID, @GangMasterID,   
 @Category,@BasicRate,@MaritalStatus, @NPWP, @TIDAKHADIR,  
 @HADIR, @Upah, @LAIN, @HariLainUpah--, @TotalBasic  
 ,@WorkingDays  
 ,@NoOfSundays  
 ,@AdjustmentDay  
    
 WHILE @@FETCH_STATUS = 0   
 BEGIN  
    
       
   SELECT @count = (ISNULL(MAX(Id),0) + 1) FROM Checkroll.Salary  ;  
   SET @SalaryID  = @EstateCode+'R'+ CONVERT(NVARCHAR,@count);  
    
    
   INSERT INTO Checkroll.Salary (  
   SalaryProcDate,   
   SalaryID,  
   EmpID,  
   EstateId,  
   ActiveMonthYearId,  
   GangMasterId,   
    Category,  
    MStatus,  
    NPWP,  
    Absent,  
    Hari,  
    Upah,   
    HariLain,  
    HarinLainUpah,  
    TotalBasic,  
    CreatedBy,CreatedOn,ModifiedBy,ModifiedOn      
   )  
   values (  
   @SalaryProcDate,  
   @SalaryID,  
   @EmpID,  
   @EstateId,  
   @ActiveMonthYearId,  
   @GangMasterId,   
    @Category,  
    @MaritalStatus,  
    @NPWP,  
    @TIDAKHADIR,  
    @HADIR,  
    @Upah,   
    @LAIN,  
    @HariLainUpah,  
    ISNULL(@Upah,0)+ISNULL(@HariLainUpah,0),        
    @User,GetDate(),@User,GetDate()   
   )  
       
     
   FETCH NEXT FROM CR_DA  
    INTO   
    @EmpID  
    ,@EmpName  
    ,@EstateID, @ActiveMonthYearID, @GangMasterID,   
    @Category,@BasicRate,@MaritalStatus, @NPWP, @TIDAKHADIR,  
    @HADIR, @Upah, @LAIN, @HariLainUpah--, @TotalBasic  
   ,@WorkingDays  
   ,@NoOfSundays  
   ,@AdjustmentDay  
         
 END  
 CLOSE CR_DA  
  
 DEALLOCATE CR_DA  
  

 

