// Copyright 2016 Proyectos y Sistemas de Mantenimiento SL (eProsima).
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/*!
 * @file PoseWithCovariancePubSubTypes.cpp
 * This header file contains the implementation of the serialization functions.
 *
 * This file was generated by the tool fastcdrgen.
 */

#include <fastcdr/FastBuffer.h>
#include <fastcdr/Cdr.h>

#include "PoseWithCovariancePubSubTypes.h"

using SerializedPayload_t = eprosima::fastrtps::rtps::SerializedPayload_t;
using InstanceHandle_t = eprosima::fastrtps::rtps::InstanceHandle_t;

namespace geometry_msgs {
    namespace msg {

        PoseWithCovariancePubSubType::PoseWithCovariancePubSubType()
        {
            // 设置消息类型的名称，表示该类型是 geometry_msgs::msg::PoseWithCovariance 类型的 DDS 消息
            setName("geometry_msgs::msg::dds_::PoseWithCovariance_");

            // 获取 PoseWithCovariance 类型的最大 CDR 序列化大小
            auto type_size = PoseWithCovariance::getMaxCdrSerializedSize();

            // 为可能存在的子消息进行对齐处理，这里假设每个子消息需要 4 字节对齐
            type_size += eprosima::fastcdr::Cdr::alignment(type_size, 4);

            // 计算最终类型的大小，并加上 4 字节用于封装（encapsulation）
            m_typeSize = static_cast<uint32_t>(type_size) + 4;

            // 检查是否已为该类型定义键（key），并将结果保存在 m_isGetKeyDefined 中
            m_isGetKeyDefined = PoseWithCovariance::isKeyDefined();

            // 计算最大键的 CDR 序列化大小，如果键的大小大于 16 字节，则使用较大的值
            size_t keyLength = PoseWithCovariance::getKeyMaxCdrSerializedSize() > 16 ?
                    PoseWithCovariance::getKeyMaxCdrSerializedSize() : 16;

            // 为键分配内存，并将其初始化为零
            m_keyBuffer = reinterpret_cast<unsigned char*>(malloc(keyLength));
            memset(m_keyBuffer, 0, keyLength);
        }

        PoseWithCovariancePubSubType::~PoseWithCovariancePubSubType()
        {
            if (m_keyBuffer != nullptr)
            {
                free(m_keyBuffer);
            }
        }

        bool PoseWithCovariancePubSubType::serialize(
                void* data,
                SerializedPayload_t* payload)
        {
            PoseWithCovariance* p_type = static_cast<PoseWithCovariance*>(data);

            // Object that manages the raw buffer.
            eprosima::fastcdr::FastBuffer fastbuffer(reinterpret_cast<char*>(payload->data), payload->max_size);
            // Object that serializes the data.
            eprosima::fastcdr::Cdr ser(fastbuffer, eprosima::fastcdr::Cdr::DEFAULT_ENDIAN, eprosima::fastcdr::Cdr::DDS_CDR);
            payload->encapsulation = ser.endianness() == eprosima::fastcdr::Cdr::BIG_ENDIANNESS ? CDR_BE : CDR_LE;
            // Serialize encapsulation
            ser.serialize_encapsulation();

            try
            {
                // Serialize the object.
                p_type->serialize(ser);
            }
            catch (eprosima::fastcdr::exception::NotEnoughMemoryException& /*exception*/)
            {
                return false;
            }

            // Get the serialized length
            payload->length = static_cast<uint32_t>(ser.getSerializedDataLength());
            return true;
        }

        bool PoseWithCovariancePubSubType::deserialize(
                SerializedPayload_t* payload,
                void* data)
        {
            try
            {
                //Convert DATA to pointer of your type
                PoseWithCovariance* p_type = static_cast<PoseWithCovariance*>(data);

                // Object that manages the raw buffer.
                eprosima::fastcdr::FastBuffer fastbuffer(reinterpret_cast<char*>(payload->data), payload->length);

                // Object that deserializes the data.
                eprosima::fastcdr::Cdr deser(fastbuffer, eprosima::fastcdr::Cdr::DEFAULT_ENDIAN, eprosima::fastcdr::Cdr::DDS_CDR);

                // Deserialize encapsulation.
                deser.read_encapsulation();
                payload->encapsulation = deser.endianness() == eprosima::fastcdr::Cdr::BIG_ENDIANNESS ? CDR_BE : CDR_LE;

                // Deserialize the object.
                p_type->deserialize(deser);
            }
            catch (eprosima::fastcdr::exception::NotEnoughMemoryException& /*exception*/)
            {
                return false;
            }

            return true;
        }

        std::function<uint32_t()> PoseWithCovariancePubSubType::getSerializedSizeProvider(
                void* data)
        {
            return [data]() -> uint32_t
                   {
                       return static_cast<uint32_t>(type::getCdrSerializedSize(*static_cast<PoseWithCovariance*>(data))) +
                              4u /*encapsulation*/;
                   };
        }

        void* PoseWithCovariancePubSubType::createData()
        {
            return reinterpret_cast<void*>(new PoseWithCovariance());
        }

        void PoseWithCovariancePubSubType::deleteData(
                void* data)
        {
            delete(reinterpret_cast<PoseWithCovariance*>(data));
        }

        bool PoseWithCovariancePubSubType::getKey(
                void* data,
                InstanceHandle_t* handle,
                bool force_md5)
        {
            if (!m_isGetKeyDefined)
            {
                return false;
            }

            PoseWithCovariance* p_type = static_cast<PoseWithCovariance*>(data);

            // Object that manages the raw buffer.
            eprosima::fastcdr::FastBuffer fastbuffer(reinterpret_cast<char*>(m_keyBuffer),
                    PoseWithCovariance::getKeyMaxCdrSerializedSize());

            // Object that serializes the data.
            eprosima::fastcdr::Cdr ser(fastbuffer, eprosima::fastcdr::Cdr::BIG_ENDIANNESS);
            p_type->serializeKey(ser);
            if (force_md5 || PoseWithCovariance::getKeyMaxCdrSerializedSize() > 16)
            {
                m_md5.init();
                m_md5.update(m_keyBuffer, static_cast<unsigned int>(ser.getSerializedDataLength()));
                m_md5.finalize();
                for (uint8_t i = 0; i < 16; ++i)
                {
                    handle->value[i] = m_md5.digest[i];
                }
            }
            else
            {
                for (uint8_t i = 0; i < 16; ++i)
                {
                    handle->value[i] = m_keyBuffer[i];
                }
            }
            return true;
        }
    } //End of namespace msg
} //End of namespace geometry_msgs
