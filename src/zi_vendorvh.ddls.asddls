@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true

define view entity ZI_VendorVH
  as select from zexp_config
{
      @Search.defaultSearchElement: true
  key config_key   as VendorId,
      config_value as VendorName,
      config_desc  as VendorDesc
}
where
  config_type = 'VENDOR'
  and is_active = 'X'
