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
using Poppler;
using Cairo;

namespace org.westhoffswelt.pdf2svg {
    /**
     * Pdf transformer
     *
     * The Transformer is used to read in a Pdf file and output seperate pages
     * of it as svg on request to a specified location.
     */
    public class Transformer: Object {
        /**
         * Poppler document object representing the opened PDF file.
         */
        protected Document document = null;         

        /**
         * Create a new Transformer and load the PDF document
         */
        public Transformer( File pdf_file ) {
            try {
                this.document = new Document.from_file( 
                    pdf_file.get_uri(), 
                    null 
                );
            }
            catch( GLib.Error e ) {
                error( "Could not initialize PDF-Transformer: %s.", e.message );
            }
        }

        /**
         * Provide the page count of the currently opened PDF document
         */
        public int get_number_of_pages() {
            return this.document.get_n_pages();
        }

        /**
         * Create a new svg under the given target filename and render the PDF
         * page corresponding to the provided page number to this file.
         */
        public void render_page_to_svg( int page_number, string target_file )
        throws GLib.Error {
            double page_width, page_height;

            Page page = this.document.get_page( page_number );
            page.get_size( out page_width, out page_height );

            Context context = new Context( 
                new SvgSurface( 
                    target_file, 
                    page_width, 
                    page_height 
                )
            );

            page.render( context );
        }
    }
}
