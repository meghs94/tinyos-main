/*
 * Copyright (c) 2005-2006 Arch Rock Corporation
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the Arched Rock Corporation nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
 * ARCHED ROCK OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE
 */

/**
 * HalTMP175ReaderP provides the service level HIL and device
 * specific Hal interfaces for the TI TMP175 Chip.
 *
 * Note that only the data path uses split phase resource arbitration
 * 
 * @author Phil Buonadonna <pbuonadonna@archrock.com>
 * @version $Revision: 1.1.2.1 $ $Date: 2006-06-19 18:20:59 $
 */

generic module HplTMP175ReaderP()
{
  provides interface Read<uint16_t> as Temperature;
  provides interface HalTMP175Advanced;

  uses interface HplTMP175;
  uses interface Resource as TMP175Resource;
}

implementation {

  enum {
    STATE_SET_MODE,
    STATE_SET_POLARITY,
    STATE_SET_FQ,
    STATE_SET_RES,
    STATE_NONE
  };

  uint8_t mState = STATE_NONE;
  uint8_t mConfigRegVal = 0;
  error_t mHplError;

  command error_t Temperature.read() {
    return call TMP175Resource.request();
  }

  event void TMP175Resource.granted() {
    error_t error;
    
    error = call HplTMP175.measureTemperature();
    if (error) {
      call TMP175Resource.release();
      signal Temperature.readDone(error,0);
    }
    return;
  }

  event void HplTMP175.measureTemperatureDone(error_t tmp175_error, uint16_t val) {
    call TMP175Resource.release();
    signal Temperature.reaDone(tmp175_error,val);
    return;
  }

  command error_t HalTMP175Advanced.setThermostatMode(bool useInt) {
    error_t error;
    uint8_t newRegVal;

    error = call TMP175Resource.immediateRequest();
    if (error) {
      return error;
    }
    mState = STATE_SET_MODE;

    if (useInt) {
      newRegVal = mConfigRegVal | TMP175_CFG_TM;
    }
    else {
      newRegVal = mConfigRegVal & ~TMP175_CFG_TM;
    }

    error = call HplTMP715.setConfigReg(newRegVal);
    if (error) {
      call TMP175Resource.release();
    }
    else {
      mConfigRegVal = newRegVal;
    }

    return error;
  }


  command error_t HalTMP175Advanced.setPolarity(bool polarity) {
    error_t error;
    uint8_t newRegVal;

    error = call TMP175Resource.immediateRequest();
    if (error) {
      return error;
    }
    mState = STATE_SET_POLARITY;

    if (useInt) {
      newRegVal = mConfigRegVal | TMP175_CFG_TM;
    }
    else {
      newRegVal = mConfigRegVal & ~TMP175_CFG_TM;
    }

    error = call HplTMP715.setConfigReg(newRegVal);
    if (error) {
      call TMP175Resource.release();
    }
    else {
      mConfigRegVal = newRegVal;
    }

    return error;
  }

  command error_t HalTMP175Advanced.setFaultQueue(tmp175_fqd_t depth) {

  }

  command error_t HalTMP175Advanced.setResolution(tmp175_res_t res) {

  }

  command error_t HalTMP175Advanced.setTLow(uint16_t val) {

  }

  command error_t HalTMP175Advanced.setTHigh(uint16_t val) {

  }

  task void handleConfigReg() {
    error_t lasterror;
    atomic lasterror = mHplError;
    call TMP175Resource.release();
    switch (mState) {
    case STATE_SET_MODE:
      signal HalTMP175Advanced.setThermostatModeDone(lasterror);
      break;
    case STATE_SET_POLARITY:
      signal HalTMP175Advanced.setPolarityDone(lasterror);
      break;
    case STATE_SET_FQ:
      signal HalTMP175Advanced.setFaultQueueDone(lasterror);
      break;
    case STATE_SET_RES:
      signal HalTMP175Advanced.setResolutionDone(lasterror);
      break;
    default:
      break;
    }
    mState = STATE_NONE;
    return;
  }

  async event void HplTMP175.setConfigRegDone(error_t error) {
    mHplError = error;
    post handleConfigReg();
    return;
  }

  async event void HplTMP175.setTLowRegDone(error_t error) {


  }

  async event void HplTMP175.setTHighRegDone(error_t error) {


  }

  async event void HplTMP175.alertThreshold() {


  }

  default event void HalTMP175Advanced.setTHighDone(error_t error) { return; }
  default event void HalTMP175Advanced.setThermostatModeDone(error_t error){ return; } 
  default event void HalTMP175Advanced.setPolarityDone(error_t error){ return; }
  default event void HalTMP175Advanced.setFaultQueueDone(error_t error){ return; }
  default event void HalTMP175Advanced.setResolutionDone(error_t error){ return; }
  default event void HalTMP175Advanced.setTLowDone(error_t error){ return; }
  default event void HalTMP175Advanced.alertThreshold(){ return; }

}
