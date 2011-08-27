# Copyright (c) 2011 Akamai Technologies, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#
#     * Redistributions in binary form must reproduce the above copyright notice,
#       this list of conditions and the following disclaimer in the documentation
#       and/or other materials provided with the distribution.
#
#     * Neither the name of Akamai Technologies, Inc. nor the names of its
#       contributors may be used to endorse or promote products derived from this
#       software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Disable pre-existing implicit rules and suffix rules for easier dep debugging.
%.o : %.s
% : RCS/%,v
% : RCS/%
% : %,v
% : s.%
% : SCCS/s.%
.SUFFIXES:
SUFFIXES :=

config.mk:
	./configure

include config.mk

# Debugging aid

pr-%:
	@echo '$*=$($*)'

# commands

gzip ?= gzip
mkdir ?= mkdir -p $@
pandoc ?= pandoc
pandoc_gz ?= $(pandoc) -s -S -r markdown -w man $< | gzip -c - > $@

# declarations

MANPAGES_GZ= $(patsubst %,man3/%.3.gz,crypto_box)

# codegen

define MAN_template
man$(1)/%.$(1).gz: docs/%.txt
	mkdir -p $$(@D) && $$(pandoc_gz)
endef
$(foreach N,1 2 3 4 5 6 7 8,$(eval $(call MAN_template,$(N))))

# targets

all: do.stamp docs

do.stamp:
	./do
	touch $@

docs: $(MANPAGES_GZ)

clean:
	rm -f $(MANPAGES_GZ) build
	rm -rf $(patsubst %,man%,1 2 3 4 5 6 7 8)

install: all
	install -d -m 0755 "$(libdir)"
	install -m 0644 build/*/lib/*/libnacl.a "$(libdir)/libnacl.a"
	install -d -m 0755 "$(includedir)/nacl"
	for f in $$(ls build/*/include/*/*); do \
		install -m 0644 $$f "$(includedir)/nacl/$$(basename $$f)" ; \
	done
	for p in $(MANPAGES_GZ); do \
		install -d -m 0755 "$(mandir)/$$(dirname $$p)"; \
		install -m 0644 $$p "$(mandir)/$$(dirname $$p)/$$(basename $$p)" ; \
	done

.PHONY: clean install all check docs
.DEFAULT_GOAL := all

# vim: noet sts=4 ts=4 sw=4 :
