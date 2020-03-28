module Msf
module Util
module DotNetDeserialization
module Types

  class Record < BinData::Record; end  # forward definition

  require 'msf/util/dot_net_deserialization/types/primitives'
  require 'msf/util/dot_net_deserialization/types/general'
  require 'msf/util/dot_net_deserialization/types/record_values'

  #
  # .NET Serialization Types (Compound-Records)
  #
  class Record < BinData::Record
    endian                 :little
    uint8                  :record_type
    choice                 :record_value, selection: -> { record_type } do
      serialization_header_record             Enums::RecordTypeEnum[:SerializedStreamHeader]
      class_with_id                           Enums::RecordTypeEnum[:ClassWithId]
      system_class_with_members               Enums::RecordTypeEnum[:SystemClassWithMembers]
      #class_with_members                      Enums::RecordTypeEnum[:ClassWithMembers]
      system_class_with_members_and_types     Enums::RecordTypeEnum[:SystemClassWithMembersAndTypes]
      class_with_members_and_types            Enums::RecordTypeEnum[:ClassWithMembersAndTypes]
      binary_object_string                    Enums::RecordTypeEnum[:BinaryObjectString]
      #binary_array                            Enums::RecordTypeEnum[:BinaryArray]
      #member_primitive_typed                  Enums::RecordTypeEnum[:MemberPrimitiveTyped]
      member_reference                        Enums::RecordTypeEnum[:MemberReference]
      object_null                             Enums::RecordTypeEnum[:ObjectNull]
      message_end                             Enums::RecordTypeEnum[:MessageEnd]
      binary_library                          Enums::RecordTypeEnum[:BinaryLibrary]
      #object_null_multiple_256                Enums::RecordTypeEnum[:ObjectNullMultiple256]
      #object_null_multiple                    Enums::RecordTypeEnum[:ObjectNullMultiple]
      #array_single_primitive                  Enums::RecordTypeEnum[:ArraySinglePrimitive]
      #array_single_object                     Enums::RecordTypeEnum[:ArraySingleObject]
      array_single_string                     Enums::RecordTypeEnum[:ArraySingleString]
      #method_call                             Enums::RecordTypeEnum[:MethodCall]
      #method_return                           Enums::RecordTypeEnum[:MethodReturn]
    end

    def self.from_value(record_value)
      raise ArgumentError unless record_value.class.const_defined?('RECORD_TYPE')

      self.new(record_type: record_value.class::RECORD_TYPE, record_value: record_value)
    end
  end

  class SerializedStream < BinData::Record
    endian                 :little
    array                  :records, type: :record, read_until: -> { records[-1]&.record_type == Enums::RecordTypeEnum[:MessageEnd] }

    def self.from_values(values)
      records = []
      values.each do |contents|
        records << Record.from_value(contents)
      end
      self.new(records: records)
    end

    def get_object(id)
      @objects = @objects || {}
      @objects[id]
    end

    def set_object(id, object)
      @objects = @objects || {}
      @objects[id] = object
    end
  end

end
end
end
end
