
/****** Object:  StoredProcedure [Checkroll].[TransferSalaryToAllowance]    Script Date: 16/12/2015 3:16:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Checkroll].[TransferSalaryToAllowance]  
@ActiveMonthYearId nvarchar (50),  
@EstateId nvarchar (50),  
@User nvarchar (50)    
AS     
  
BEGIN  
declare @Percentage numeric(10,4)
declare @EmpId nvarchar(50)
declare @AllowDecCode varchar(50)
declare @TotalBasic numeric(18,2)
declare @AllowanceRice numeric(18,2)
declare @EstateCode varchar(10)
declare @until datetime
declare @tanggal datetime
declare @from datetime
declare @id varchar(15)
Declare @OTNormal numeric(18,2)
Declare @OTLembur100 numeric(18,2)
declare @PremiDasarLatex numeric(18,2),@PremiDasarLump numeric(18,2),@PremiProgresifLatex numeric(18,2),@PremiProgresifLump numeric(18,2),@PremiBonusLatex numeric(18,2),@PremiBonusLump numeric(18,2),@PremiMinggu numeric(18,2),@PremiTreelace numeric(18,2)
DECLARE @AdvancePremium numeric(18,2)

select @estateCode =EstateCode from General.Estate  where EstateID=@EstateId
set @tanggal= getDate()


select @from=FromDT,@until=ToDT from General.ActiveMonthYear AM 
inner join General.FiscalYear FY on AM.AMonth = FY.Period and  AM.AYear = FY.FYear
where ActiveMonthYearID = @ActiveMonthYearId

 DECLARE cData CURSOR FOR   
  
 --Transfer Basic and Allowance Rice for KT
select Empid,IsNull(TotalBasic,0), IsNull(AllowanceRiceForKT,0),Isnull(DedAdvance,0) from Checkroll.Salary
where Checkroll.Salary.ActiveMonthYearID=@ActiveMonthYearId and Checkroll.Salary.EstateID = @EstateId

Open cData  
  
 FETCH NEXT FROM cData  
 INTO  @EmpId, @TotalBasic,@AllowanceRice,@AdvancePremium
     
 WHILE @@FETCH_STATUS = 0   
 BEGIN  
	
	--Total Basic
	select @AllowDecCode = AllowDedID from Checkroll.AllowanceDeductionSetup where AllowDedCode = 'A01'
	select @id = EmpAllowDedID from Checkroll.EmpAllowanceDeduction where EmpID=@EmpId and AllowDedID =@AllowDecCode and StartDate = @from and EndDates = @until
	if(@@ROWCOUNT=0)
		exec [Checkroll].[EmpAllowanceDeductionInsert]    
		@id output,@EstateId,@EstateCode,@EmpId,@allowDecCode,
	 	 @TotalBasic,'A',@from,@until,@User,@tanggal,@User,@tanggal
	else
		exec[Checkroll].[EmpAllowanceDeductionUpdate] @id output,@EstateId,@EmpId,@allowDecCode,
	 	 @TotalBasic,'A',@from,@until,@User,@tanggal
	
	-- Rice Allowance In and out
	select @AllowDecCode = AllowDedID from Checkroll.AllowanceDeductionSetup where AllowDedCode = 'A05'
	select @id = EmpAllowDedID from Checkroll.EmpAllowanceDeduction where EmpID=@EmpId and AllowDedID =@AllowDecCode and StartDate = @from and EndDates = @until
	if(@@ROWCOUNT=0)
		exec [Checkroll].[EmpAllowanceDeductionInsert]    
		@id output,@EstateId,@EstateCode,@EmpId,@allowDecCode,
	 	 @AllowanceRice,'A',@from,@until,@User,@tanggal,@User,@tanggal
	else
		exec[Checkroll].[EmpAllowanceDeductionUpdate] @id output,@EstateId,@EmpId,@allowDecCode,
	 	 @AllowanceRice,'A',@from,@until,@User,@tanggal
	--Deduction Beras
	select @AllowDecCode = AllowDedID from Checkroll.AllowanceDeductionSetup where AllowDedCode = 'D05'
	select @id = EmpAllowDedID from Checkroll.EmpAllowanceDeduction where EmpID=@EmpId and AllowDedID =@AllowDecCode and StartDate = @from and EndDates = @until
	if(@@ROWCOUNT=0)
		exec [Checkroll].[EmpAllowanceDeductionInsert]    
		@id output,@EstateId,@EstateCode,@EmpId,@allowDecCode,
	 	 @AllowanceRice,'D',@from,@until,@User,@tanggal,@User,@tanggal
	else
		exec[Checkroll].[EmpAllowanceDeductionUpdate] @id output,@EstateId,@EmpId,@allowDecCode,
	 	 @AllowanceRice,'D',@from,@until,@User,@tanggal
	
	-- OT Normal
	select @AllowDecCode = AllowDedID from Checkroll.AllowanceDeductionSetup where AllowDedCode = 'A02'
	select @OTNormal = Isnull(Sum(OTValue1+OTValue2+OTValue3),0), @OTLembur100 = IsNull(Sum(OTValue4),0) from checkroll.OTDetail where EmpID=@EmpId and ActiveMonthYearID = @ActiveMonthYearId
	select @id = EmpAllowDedID from Checkroll.EmpAllowanceDeduction where EmpID=@EmpId and AllowDedID =@AllowDecCode and StartDate = @from and EndDates = @until  
	if(@@ROWCOUNT=0)
		exec [Checkroll].[EmpAllowanceDeductionInsert]    
		@id output,@EstateId,@EstateCode,@EmpId,@allowDecCode,
	 	 @OTNormal,'A',@from,@until,@User,@tanggal,@User,@tanggal
	else
		exec[Checkroll].[EmpAllowanceDeductionUpdate] @id output,@EstateId,@EmpId,@allowDecCode,
	 	 @OTNormal,'A',@from,@until,@User,@tanggal

	--OT Lembur
	select @AllowDecCode = AllowDedID from Checkroll.AllowanceDeductionSetup where AllowDedCode = 'A27'
	select @id = EmpAllowDedID from Checkroll.EmpAllowanceDeduction where EmpID=@EmpId and AllowDedID =@AllowDecCode and StartDate = @from and EndDates = @until  
	if(@@ROWCOUNT=0)
		exec [Checkroll].[EmpAllowanceDeductionInsert]    
		@id output,@EstateId,@EstateCode,@EmpId,@allowDecCode,
	 	 @OTLembur100,'A',@from,@until,@User,@tanggal,@User,@tanggal
	else
		exec[Checkroll].[EmpAllowanceDeductionUpdate] @id output,@EstateId,@EmpId,@allowDecCode,
	 	 @OTLembur100,'A',@from,@until,@User,@tanggal
	 
	 --Premi Panen Reuse OTVariables for saving to db
	select @AllowDecCode = AllowDedID from Checkroll.AllowanceDeductionSetup where AllowDedCode = 'A08'
	select @OTNormal= Isnull(Sum(Tvalue1+Tvalue2+TValue3),0), @OTLembur100 = Isnull(Sum(TLooseFruitsValue),0) from Checkroll.ReceptionTargetDetail where EmpID=@EmpId and ActiveMonthYearID = @ActiveMonthYearId
	select @id = EmpAllowDedID from Checkroll.EmpAllowanceDeduction where EmpID=@EmpId and AllowDedID =@AllowDecCode and StartDate = @from and EndDates = @until  
	if(@@ROWCOUNT=0)
		exec [Checkroll].[EmpAllowanceDeductionInsert]    
		@id output,@EstateId,@EstateCode,@EmpId,@allowDecCode,
	 	 @OTNormal,'A',@from,@until,@User,@tanggal,@User,@tanggal
	else
		exec[Checkroll].[EmpAllowanceDeductionUpdate] @id output,@EstateId,@EmpId,@allowDecCode,
	 	 @OTNormal,'A',@from,@until,@User,@tanggal
	
	--Premi Mandor Panen
    select @AllowDecCode = AllowDedID from Checkroll.AllowanceDeductionSetup where AllowDedCode = 'A43'
	select @OTNormal= Isnull(Sum(MandorPremi),0) from checkroll.DailyTeamActivity where MandoreID=@EmpId and DDate between @from and @until And Activity = 'Panen'
	select @id = EmpAllowDedID from Checkroll.EmpAllowanceDeduction where EmpID=@EmpId and AllowDedID =@AllowDecCode and StartDate = @from and EndDates = @until  
	if(@@ROWCOUNT=0)
		exec [Checkroll].[EmpAllowanceDeductionInsert]    
		@id output,@EstateId,@EstateCode,@EmpId,@allowDecCode,
	 	 @OTNormal,'A',@from,@until,@User,@tanggal,@User,@tanggal
	else
		exec[Checkroll].[EmpAllowanceDeductionUpdate] @id output,@EstateId,@EmpId,@allowDecCode,
	 	 @OTNormal,'A',@from,@until,@User,@tanggal
	
	--Premi Mandor Karet
	select @AllowDecCode = AllowDedID from Checkroll.AllowanceDeductionSetup where AllowDedCode = 'A44'
	select @OTNormal= Isnull(Sum(MandorPremi),0) from checkroll.DailyTeamActivity where MandoreID=@EmpId and DDate between @from and @until And Activity = 'Deres'
	select @id = EmpAllowDedID from Checkroll.EmpAllowanceDeduction where EmpID=@EmpId and AllowDedID =@AllowDecCode and StartDate = @from and EndDates = @until  
	if(@@ROWCOUNT=0)
		exec [Checkroll].[EmpAllowanceDeductionInsert]    
		@id output,@EstateId,@EstateCode,@EmpId,@allowDecCode,
	 	 @OTNormal,'A',@from,@until,@User,@tanggal,@User,@tanggal
	else
		exec[Checkroll].[EmpAllowanceDeductionUpdate] @id output,@EstateId,@EmpId,@allowDecCode,
	 	 @OTNormal,'A',@from,@until,@User,@tanggal

	--Premi Kerani Panen
	select @AllowDecCode = AllowDedID from Checkroll.AllowanceDeductionSetup where AllowDedCode = 'A45'
	select @OTNormal= Isnull(Sum(KraniPremi),0) from checkroll.DailyTeamActivity where MandoreID=@EmpId and DDate between @from and @until And Activity = 'Panen'
	select @id = EmpAllowDedID from Checkroll.EmpAllowanceDeduction where EmpID=@EmpId and AllowDedID =@AllowDecCode and StartDate = @from and EndDates = @until  
	if(@@ROWCOUNT=0)
		exec [Checkroll].[EmpAllowanceDeductionInsert]    
		@id output,@EstateId,@EstateCode,@EmpId,@allowDecCode,
	 	 @OTNormal,'A',@from,@until,@User,@tanggal,@User,@tanggal
	else
		exec[Checkroll].[EmpAllowanceDeductionUpdate] @id output,@EstateId,@EmpId,@allowDecCode,
	 	 @OTNormal,'A',@from,@until,@User,@tanggal
	
	--Premi Kerani Deres
	select @AllowDecCode = AllowDedID from Checkroll.AllowanceDeductionSetup where AllowDedCode = 'A46'
	select @OTNormal= Isnull(Sum(KraniPremi),0) from checkroll.DailyTeamActivity where MandoreID=@EmpId and DDate between @from and @until And Activity = 'Deres'
	select @id = EmpAllowDedID from Checkroll.EmpAllowanceDeduction where EmpID=@EmpId and AllowDedID =@AllowDecCode and StartDate = @from and EndDates = @until  
	if(@@ROWCOUNT=0)
		exec [Checkroll].[EmpAllowanceDeductionInsert]    
		@id output,@EstateId,@EstateCode,@EmpId,@allowDecCode,
	 	 @OTNormal,'A',@from,@until,@User,@tanggal,@User,@tanggal
	else
		exec[Checkroll].[EmpAllowanceDeductionUpdate] @id output,@EstateId,@EmpId,@allowDecCode,
	 	 @OTNormal,'A',@from,@until,@User,@tanggal


	--Premi Brondoloan
	select @AllowDecCode = AllowDedID from Checkroll.AllowanceDeductionSetup where AllowDedCode = 'A10'
	select @id = EmpAllowDedID from Checkroll.EmpAllowanceDeduction where EmpID=@EmpId and AllowDedID =@AllowDecCode and StartDate = @from and EndDates = @until  
	if(@@ROWCOUNT=0)
		exec [Checkroll].[EmpAllowanceDeductionInsert]    
		@id output,@EstateId,@EstateCode,@EmpId,@allowDecCode,
	 	 @OTLembur100,'A',@from,@until,@User,@tanggal,@User,@tanggal
	else
		exec[Checkroll].[EmpAllowanceDeductionUpdate] @id output,@EstateId,@EmpId,@allowDecCode,
	 	 @OTLembur100,'A',@from,@until,@User,@tanggal
	 
	 --Premi Dasar Latex
	select @AllowDecCode = AllowDedID from Checkroll.AllowanceDeductionSetup where AllowDedCode = 'A15'
	select @PremiDasarLatex=Isnull(Sum(PremiDasarLatex),0),@PremiDasarLump=Isnull(Sum(PremiDasarLump),0),@PremiProgresifLatex=Isnull(Sum(PremiProgresifLatex),0),@PremiProgresifLump=Isnull(Sum(PremiProgresifLump),0),@PremiBonusLatex=Isnull(Sum(PremiBonusLatex),0),
	@PremiBonusLump=Isnull(Sum(PremiBonusLump),0),@PremiMinggu=Isnull(Sum(PremiMinggu),0),@PremiTreelace=Isnull(Sum(PremiTreelace),0) 
	from Checkroll.DailyReceptionForRubber
	inner join checkroll.CREmployee on nik =  checkroll.CREmployee.EmpCode
	where checkroll.CREmployee.EmpID=@EmpId and DateRubber Between @from and @until
	select @id = EmpAllowDedID from Checkroll.EmpAllowanceDeduction where EmpID=@EmpId and AllowDedID =@AllowDecCode and StartDate = @from and EndDates = @until  
	if(@@ROWCOUNT=0)
		exec [Checkroll].[EmpAllowanceDeductionInsert]    
		@id output,@EstateId,@EstateCode,@EmpId,@allowDecCode,
	 	 @PremiDasarLatex,'A',@from,@until,@User,@tanggal,@User,@tanggal
	else
		exec[Checkroll].[EmpAllowanceDeductionUpdate] @id output,@EstateId,@EmpId,@allowDecCode,
	 	 @PremiDasarLatex,'A',@from,@until,@User,@tanggal
	
	--Premi Dasar Cuplump
	select @AllowDecCode = AllowDedID from Checkroll.AllowanceDeductionSetup where AllowDedCode = 'A16'
	select @id = EmpAllowDedID from Checkroll.EmpAllowanceDeduction where EmpID=@EmpId and AllowDedID =@AllowDecCode and StartDate = @from and EndDates = @until  
	if(@@ROWCOUNT=0)
		exec [Checkroll].[EmpAllowanceDeductionInsert]    
		@id output,@EstateId,@EstateCode,@EmpId,@allowDecCode,
	 	 @PremiDasarLump,'A',@from,@until,@User,@tanggal,@User,@tanggal
	else
		exec[Checkroll].[EmpAllowanceDeductionUpdate] @id output,@EstateId,@EmpId,@allowDecCode,
	 	 @PremiDasarLump,'A',@from,@until,@User,@tanggal

	--Premi Progressif Latex
	select @AllowDecCode = AllowDedID from Checkroll.AllowanceDeductionSetup where AllowDedCode = 'A20'
	select @id = EmpAllowDedID from Checkroll.EmpAllowanceDeduction where EmpID=@EmpId and AllowDedID =@AllowDecCode and StartDate = @from and EndDates = @until  
	if(@@ROWCOUNT=0)
		exec [Checkroll].[EmpAllowanceDeductionInsert]    
		@id output,@EstateId,@EstateCode,@EmpId,@allowDecCode,
	 	 @PremiProgresifLatex,'A',@from,@until,@User,@tanggal,@User,@tanggal
	else
		exec[Checkroll].[EmpAllowanceDeductionUpdate] @id output,@EstateId,@EmpId,@allowDecCode,
	 	 @PremiProgresifLatex,'A',@from,@until,@User,@tanggal

	--Premi Progressif Lump
	select @AllowDecCode = AllowDedID from Checkroll.AllowanceDeductionSetup where AllowDedCode = 'A21'
	select @id = EmpAllowDedID from Checkroll.EmpAllowanceDeduction where EmpID=@EmpId and AllowDedID =@AllowDecCode and StartDate = @from and EndDates = @until  
	if(@@ROWCOUNT=0)
		exec [Checkroll].[EmpAllowanceDeductionInsert]    
		@id output,@EstateId,@EstateCode,@EmpId,@allowDecCode,
	 	 @PremiProgresifLump,'A',@from,@until,@User,@tanggal,@User,@tanggal
	else
		exec[Checkroll].[EmpAllowanceDeductionUpdate] @id output,@EstateId,@EmpId,@allowDecCode,
	 	 @PremiProgresifLump,'A',@from,@until,@User,@tanggal
	
	
	--Premi Bonus Latex
	select @AllowDecCode = AllowDedID from Checkroll.AllowanceDeductionSetup where AllowDedCode = 'A18'
	select @id = EmpAllowDedID from Checkroll.EmpAllowanceDeduction where EmpID=@EmpId and AllowDedID =@AllowDecCode and StartDate = @from and EndDates = @until  
	if(@@ROWCOUNT=0)
		exec [Checkroll].[EmpAllowanceDeductionInsert]    
		@id output,@EstateId,@EstateCode,@EmpId,@allowDecCode,
	 	 @PremiBonusLatex,'A',@from,@until,@User,@tanggal,@User,@tanggal
	else
		exec[Checkroll].[EmpAllowanceDeductionUpdate] @id output,@EstateId,@EmpId,@allowDecCode,
	 	 @PremiBonusLatex,'A',@from,@until,@User,@tanggal

	 --Premi Bonus Lump
	select @AllowDecCode = AllowDedID from Checkroll.AllowanceDeductionSetup where AllowDedCode = 'A19'
	select @id = EmpAllowDedID from Checkroll.EmpAllowanceDeduction where EmpID=@EmpId and AllowDedID =@AllowDecCode and StartDate = @from and EndDates = @until  
	if(@@ROWCOUNT=0)
		exec [Checkroll].[EmpAllowanceDeductionInsert]    
		@id output,@EstateId,@EstateCode,@EmpId,@allowDecCode,
	 	 @PremiBonusLump,'A',@from,@until,@User,@tanggal,@User,@tanggal
	else
		exec[Checkroll].[EmpAllowanceDeductionUpdate] @id output,@EstateId,@EmpId,@allowDecCode,
	 	 @PremiBonusLump,'A',@from,@until,@User,@tanggal

	--Premi Minggu
	select @AllowDecCode = AllowDedID from Checkroll.AllowanceDeductionSetup where AllowDedCode = 'A31'
	select @id = EmpAllowDedID from Checkroll.EmpAllowanceDeduction where EmpID=@EmpId and AllowDedID =@AllowDecCode and StartDate = @from and EndDates = @until  
	if(@@ROWCOUNT=0)
		exec [Checkroll].[EmpAllowanceDeductionInsert]    
		@id output,@EstateId,@EstateCode,@EmpId,@allowDecCode,
	 	 @PremiMinggu,'A',@from,@until,@User,@tanggal,@User,@tanggal
	else
		exec[Checkroll].[EmpAllowanceDeductionUpdate] @id output,@EstateId,@EmpId,@allowDecCode,
	 	 @PremiMinggu,'A',@from,@until,@User,@tanggal

	--Premi Treelace
	select @AllowDecCode = AllowDedID from Checkroll.AllowanceDeductionSetup where AllowDedCode = 'A17'
	select @id = EmpAllowDedID from Checkroll.EmpAllowanceDeduction where EmpID=@EmpId and AllowDedID =@AllowDecCode and StartDate = @from and EndDates = @until  
	if(@@ROWCOUNT=0)
		exec [Checkroll].[EmpAllowanceDeductionInsert]    
		@id output,@EstateId,@EstateCode,@EmpId,@allowDecCode,
	 	 @PremiTreelace,'A',@from,@until,@User,@tanggal,@User,@tanggal
	else
		exec[Checkroll].[EmpAllowanceDeductionUpdate] @id output,@EstateId,@EmpId,@allowDecCode,
	 	 @PremiTreelace,'A',@from,@until,@User,@tanggal
	
	--Advance Deduction
	select @AllowDecCode = AllowDedID from Checkroll.AllowanceDeductionSetup where AllowDedCode = 'D06'
	select @id = EmpAllowDedID from Checkroll.EmpAllowanceDeduction where EmpID=@EmpId and AllowDedID =@AllowDecCode and StartDate = @from and EndDates = @until  
	if(@@ROWCOUNT=0)
		exec [Checkroll].[EmpAllowanceDeductionInsert]    
		@id output,@EstateId,@EstateCode,@EmpId,@allowDecCode,
	 	 @AdvancePremium,'D',@from,@until,@User,@tanggal,@User,@tanggal
	else
		exec[Checkroll].[EmpAllowanceDeductionUpdate] @id output,@EstateId,@EmpId,@allowDecCode,
	 	 @AdvancePremium,'D',@from,@until,@User,@tanggal
	
	--THR
	select @OTNormal = Netto from Checkroll.THR where empid = @EmpId and ActiveMonthYearID = @ActiveMonthYearId
	select @AllowDecCode = AllowDedID from Checkroll.AllowanceDeductionSetup where AllowDedCode = 'A40'
	select @id = EmpAllowDedID from Checkroll.EmpAllowanceDeduction where EmpID=@EmpId and AllowDedID =@AllowDecCode and StartDate = @from and EndDates = @until  
	if(@@ROWCOUNT=0)
		exec [Checkroll].[EmpAllowanceDeductionInsert]    
		@id output,@EstateId,@EstateCode,@EmpId,@allowDecCode,
	 	 @OTNormal,'A',@from,@until,@User,@tanggal,@User,@tanggal
	else
		exec[Checkroll].[EmpAllowanceDeductionUpdate] @id output,@EstateId,@EmpId,@allowDecCode,
	 	 @OTNormal,'A',@from,@until,@User,@tanggal

	select @AllowDecCode = AllowDedID from Checkroll.AllowanceDeductionSetup where AllowDedCode = 'D38'
	select @id = EmpAllowDedID from Checkroll.EmpAllowanceDeduction where EmpID=@EmpId and AllowDedID =@AllowDecCode and StartDate = @from and EndDates = @until  
	if(@@ROWCOUNT=0)
		exec [Checkroll].[EmpAllowanceDeductionInsert]    
		@id output,@EstateId,@EstateCode,@EmpId,@allowDecCode,
	 	 @OTNormal,'D',@from,@until,@User,@tanggal,@User,@tanggal
	else
		exec[Checkroll].[EmpAllowanceDeductionUpdate] @id output,@EstateId,@EmpId,@allowDecCode,
	 	 @OTNormal,'D',@from,@until,@User,@tanggal
	

   FETCH NEXT FROM cData  
     INTO @EmpId, @TotalBasic,@AllowanceRice,@AdvancePremium
         
 END  
    
 CLOSE cData  
 DEALLOCATE cData  
execute Checkroll.MonthlyTaxProcess @ActiveMonthYearId,@EstateId,@User  
delete from Checkroll.EmpAllowanceDeduction where Amount = 0
     
END
