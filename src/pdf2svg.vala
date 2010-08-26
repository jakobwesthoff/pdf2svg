/**
 * Copyright 2010 Jakob Westhoff. All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *    1. Redistributions of source code must retain the above copyright notice,
 *       this list of conditions and the following disclaimer.
 * 
 *    2. Redistributions in binary form must reproduce the above copyright notice,
 *       this list of conditions and the following disclaimer in the documentation
 *       and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY JAKOB WESTHOFF ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL JAKOB WESTHOFF OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * The views and conclusions contained in the software and documentation are those
 * of the authors and should not be interpreted as representing official policies,
 * either expressed or implied, of Jakob Westhoff
 */

using GLib;

namespace org.westhoffswelt.pdf2svg {

    public class Pdf2Svg: Object {
        protected int run( string[] args ) {
            var pdf_file = File.new_for_commandline_arg( args[1] );
            var page_number = args[2].to_int();
            var output = args[3];
            
            try {
                var document = new Poppler.Document.from_file( pdf_file.get_uri(), null );
                var page = document.get_page( page_number );

                double width, height;
                page.get_size( out width, out height );
                
                var surface = new Cairo.SvgSurface( output, width, height );
                var context = new Cairo.Context( surface );

                page.render( context );

                return 0;
            }
            catch( Error e ) {
                error( "Oops: %s", e.message );
            }
        }

        /**
         * Application entry point
         */
        public static int main ( string[] args ) {
            var pdf2svg = new Pdf2Svg();
            return pdf2svg.run( args );
        }

    }

}
