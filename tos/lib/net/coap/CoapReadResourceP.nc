/*
 * Copyright (c) 2011 University of Bremen, TZI
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the copyright holders nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

generic module CoapReadResourceP(typedef val_t, uint8_t uri_key) {
  provides interface ReadResource;
  uses interface Leds;
  uses interface Timer<TMilli> as PreAckTimer;
  uses interface Read<val_t>;
} implementation {

  bool lock = FALSE;
  coap_tid_t temp_id;

  command error_t ReadResource.get(coap_tid_t id) {

    // 	printf("ReadResource.get: %hu\n", uri_key);

    if (lock == FALSE) {
      lock = TRUE;

      temp_id = id;
      call PreAckTimer.startOneShot(COAP_PREACK_TIMEOUT);
      call Read.read();
      return SUCCESS;
    } else {
      return EBUSY;
    }
  }

  event void PreAckTimer.fired() {
    call Leds.led2Toggle();
    signal ReadResource.getDoneDeferred(temp_id);
  }

  event void Read.readDone(error_t result, val_t val) {
    uint8_t asyn_message = 1;

    if (call PreAckTimer.isRunning()) {
      call PreAckTimer.stop();
      asyn_message = 0;
    }

    //printf("ReadResource.readDone\n");
    signal ReadResource.getDone(result, temp_id, asyn_message, (uint8_t*)&val, sizeof(val_t));
    lock = FALSE;
  }
}
