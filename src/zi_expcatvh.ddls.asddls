@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Expense Category Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true

define view entity ZI_ExpCatVH
  as select from I_Language
{
      @Search.defaultSearchElement: true
  key cast( 'MAINT' as abap.char(10) )          as ExpCatId,
      cast( 'Maintenance' as abap.char(60) )     as ExpCatName
}
where Language = $session.system_language

union select from I_Language
{ key cast( 'HKPNG' as abap.char(10) )          as ExpCatId,
      cast( 'Housekeeping' as abap.char(60) )    as ExpCatName }
where Language = $session.system_language

union select from I_Language
{ key cast( 'VISMD' as abap.char(10) )                as ExpCatId,
      cast( 'Visual Merchandising' as abap.char(60) )  as ExpCatName }
where Language = $session.system_language

union select from I_Language
{ key cast( 'UTILS' as abap.char(10) )          as ExpCatId,
      cast( 'Utilities' as abap.char(60) )       as ExpCatName }
where Language = $session.system_language

union select from I_Language
{ key cast( 'REPRS' as abap.char(10) )          as ExpCatId,
      cast( 'Repairs' as abap.char(60) )         as ExpCatName }
where Language = $session.system_language
