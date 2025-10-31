<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class ProviderOTPMail extends Mailable
{
    use Queueable, SerializesModels;

    public $otp;

    public function __construct($otp)
    {
        $this->otp = $otp;
    }

   public function build()
{
    return $this->subject('Your Login OTP')
                ->html("<h2>Hello!</h2><p>Your login OTP is: <strong>{$this->otp}</strong></p>");
}

}